import Vapor
import Fluent

struct FunctionController : RouteCollection{
    func boot(routes: any RoutesBuilder) throws {
        let functions = routes.grouped("functions")
        
        functions.get(use: self.getFunctions)
        functions.post(use: self.create)
        functions.get("movieFunctions", use: self.getFunctionsByMovie)
        functions.get("moviesFiltered", use: self.getMoviesByFunctionsAndCategory)
        functions.get("byId", use: self.getFunctionById)
        functions.put("updateAvailability", use: self.updateAvailability)
        functions.delete(use: self.deleteFunction)
        functions.get("premieres", use: self.getPremieres)
    }

    func create(req: Request) async throws -> ResponseFunctionDTO{
        let dto = try req.content.decode(CreateFunctionDTO.self)
        let function = Function(functionDate: dto.functionDate, room: dto.room, availability: dto.availability, movieID: dto.id_movie)
        try await function.save(on: req.db)
        try await function.$movie.load(on: req.db) 
        return try ResponseFunctionDTO(function: function)
    }

    func getFunctions(req: Request) async throws -> [ResponseFunctionDTO] {
        var functionsMock : [ResponseFunctionDTO] = []
        let functionsDB = try await Function.query(on:req.db).with(\.$movie).all()
        try functionsDB.forEach{ function in
            var functionDTO = try ResponseFunctionDTO(function: function)
            functionsMock.append(functionDTO)
        }
        return functionsMock
    }

    func getFunctionsByMovie(req: Request) async throws -> [ResponseFunctionDTO]{
        struct FunctionsMovieDTO : Content{
            let movieID : Int
            let day : Int
            let month: Int
            let year: Int
            let premiere: Bool
        }
        let calendar = Calendar.current
        guard let mexicoCityTimeZone = TimeZone(identifier: "America/Mexico_City") else {
            fatalError("No se pudo encontrar la zona horaria de la Ciudad de México.")
        }
        let desiredComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        var functionsMock : [ResponseFunctionDTO] = []
        let dto = try req.content.decode(FunctionsMovieDTO.self)
        var functionsDB : [Function] = []
        if(dto.premiere == false){
            functionsDB = try await Function.query(on:req.db)
            .join(parent: \Function.$movie)
            .filter(Movie.self, \.$id == dto.movieID)
            .with(\.$movie)
            .all()
        }else{
            functionsDB = try await Function.query(on:req.db)
            .join(parent: \Function.$movie)
            .filter(Movie.self, \.$id == dto.movieID)
            .filter(Movie.self, \.$premiere == true)
            .with(\.$movie)
            .all()
        }
        try functionsDB.forEach{ function in
                var functionDTO = try ResponseFunctionDTO(function: function)
                let dateComponents = calendar.dateComponents(in: mexicoCityTimeZone, from: function.functionDate)
                if(dateComponents.day == dto.day && dateComponents.month == dto.month && dateComponents.year == dto.year){
                    functionsMock.append(functionDTO)
                }
        }
        return functionsMock
    }

    func getMoviesByFunctionsAndCategory(req: Request) async throws -> [ResponseMovieDTO]{
        //obtener todas las movies que tengan una funcion con los filtros especificados
        struct MoviesFilteredDTO : Content{
            let day : Int
            let month: Int
            let year: Int
            let genre: String
            let premiere: Bool
        }
        let calendar = Calendar.current
        guard let mexicoCityTimeZone = TimeZone(identifier: "America/Mexico_City") else {
            fatalError("No se pudo encontrar la zona horaria de la Ciudad de México.")
        }
        let desiredComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        let dto = try req.content.decode(MoviesFilteredDTO.self)
        var moviesMock : [ResponseMovieDTO] = []
        var functionsDB : [Function] = []
        if(dto.premiere == false){
            if(dto.genre == "any"){
                functionsDB = try await Function.query(on:req.db)
                .join(parent: \Function.$movie)
                .with(\.$movie)
                .all()
            }else{
                functionsDB = try await Function.query(on:req.db)
                .join(parent: \Function.$movie)
                .filter(Movie.self, \.$genre == dto.genre)
                .with(\.$movie)
                .all()
            }
        }else{
            if(dto.genre == "any"){
                functionsDB = try await Function.query(on:req.db)
                .join(parent: \Function.$movie)
                .filter(Movie.self, \.$premiere == true)
                .with(\.$movie)
                .all()
            }else{
                functionsDB = try await Function.query(on:req.db)
                .join(parent: \Function.$movie)
                .filter(Movie.self, \.$genre == dto.genre)
                .filter(Movie.self, \.$premiere == true)
                .with(\.$movie)
                .all()
            }
        }
        try functionsDB.forEach{ function in
                var functionDTO = try ResponseFunctionDTO(function: function)
                let dateComponents = calendar.dateComponents(in: mexicoCityTimeZone, from: function.functionDate)
                if(dateComponents.day == dto.day && dateComponents.month == dto.month && dateComponents.year == dto.year){
                    var movie = try ResponseMovieDTO(movie: functionDTO.movie)
                    moviesMock.append(movie)
                }
        }
        return moviesMock
    }

    func getPremieres(req:Request) async throws -> [ResponseFunctionDTO]{
        var functionsMock : [ResponseFunctionDTO] = []
        var functionsDB = try await Function.query(on:req.db)
            .join(parent: \Function.$movie)
            .filter(Movie.self, \.$premiere == true)
            .with(\.$movie)
            .all()
        try functionsDB.forEach{ function in
            var functionDTO = try ResponseFunctionDTO(function: function)
            functionsMock.append(functionDTO)
        }
        return functionsMock
    }

    func getFunctionById(req: Request) async throws -> ResponseFunctionDTO{
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "ID de venta inválido")
        }
        var functionDB = try await Function.query(on:req.db)
            .join(parent: \Function.$movie)
            .filter(Movie.self, \.$id == id)
            .with(\.$movie)
            .first()
        guard let functionUnwrapped = functionDB else {
            throw Abort(.notFound, reason: "Función no encontrada")
        }
        var function = try ResponseFunctionDTO(function: functionUnwrapped)
        return function
    }


    func updateAvailability(req: Request) async throws -> String {
        struct UpdateAvailabilityDTO: Content {
            let id: Int
            let availability: String
        }

        let dto = try req.content.decode(UpdateAvailabilityDTO.self)
        guard let function = try await Function.query(on: req.db)
            .filter(\.$id == dto.id) // dto.id debe ser el id de la función
            .first()
        else {
            throw Abort(.notFound, reason: "Function not found")
        }
        function.availability.append(dto.availability)
        try await function.save(on: req.db)
        return function.availability
    }

    func deleteFunction(req: Request) async throws -> String {
        guard let id = try req.query.get(Int?.self, at: "id") else {
            throw Abort(.badRequest, reason: "Missing id query parameter")
        }
        guard let function = try await Function.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Function not found")
        }
        try await function.delete(on: req.db)
        return "Function deleted successfully"
    }
}