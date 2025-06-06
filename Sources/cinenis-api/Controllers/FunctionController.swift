import Vapor
import Fluent

struct FunctionController : RouteCollection{
    func boot(routes: any RoutesBuilder) throws {
        let functions = routes.grouped("functions")
        
        functions.get(use: self.getFunctions)
        functions.post(use: self.create)
        
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
}