import Vapor
import Fluent

struct FunctionController : RouteCollection{
    func boot(routes: any RoutesBuilder) throws {
        let functions = routes.grouped("functions")
        
        functions.get(use: self.getFunctions)
        functions.post(use: self.create)
        functions.get("filter", use: self.getFilteredFunctions)
        functions.put("updateAvailability", use: self.updateAvailability)
        functions.delete(use: self.deleteFunction)
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

    func getFilteredFunctions(req: Request) async throws -> [ResponseFunctionDTO]{
        let calendar = Calendar.current
        guard let mexicoCityTimeZone = TimeZone(identifier: "America/Mexico_City") else {
            fatalError("No se pudo encontrar la zona horaria de la Ciudad de México.")
        }
        let desiredComponents: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute]
        var functionsMock : [ResponseFunctionDTO] = []
        let dto = try req.content.decode(MovieFunctionDTO.self)
        var functionsDB : [Function] = []
        if dto.genre == "any"{
            //obtener todas las funciones del dia por pelicula
            functionsDB = try await Function.query(on:req.db)
            .join(parent: \Function.$movie)
            .filter(Movie.self, \.$id == dto.movieID)
            .with(\.$movie)
            .all()
        }else{
            //obtener las funciones del dia por pelicula que cumpla el filtro de genre
            functionsDB = try await Function.query(on:req.db)
            .join(parent: \Function.$movie)
            .filter(Movie.self, \.$id == dto.movieID)
            .filter(Movie.self, \.$genre == dto.genre)
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
        function.availability = dto.availability
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