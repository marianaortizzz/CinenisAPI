import Vapor
import Fluent

struct SalesController : RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        let sales = routes.grouped("sales")

        sales.get(use: self.getSales)
        sales.post(use: self.create)
        sales.get(":id", use: self.getSaleByID)
        
    }

    func getSales(req: Request) async throws -> [ResponseSaleDTO] {
        var salesMock : [ResponseSaleDTO] = []
        let salesDB = try await Sale.query(on: req.db).with(\.$function).all()
        try salesDB.forEach{ sale in 
            var saleDTO = try ResponseSaleDTO(sale: sale)
            salesMock.append(saleDTO)
        }
        return salesMock
    }

    func create(req: Request) async throws -> ResponseSaleDTO {
        let dto = try req.content.decode(CreateSaleDTO.self)
        let sale = Sale(
            saleDate: dto.saleDate, 
            username: dto.username, 
            mail: dto.mail, 
            total: dto.total, 
            numberOfSeats: dto.numberOfSeats, 
            seatsReserved: dto.seatsReserved, 
            functionID: dto.functionID)
        try await sale.save(on: req.db)
        try await sale.$function.load(on: req.db)
        return try ResponseSaleDTO(sale: sale)
    }

    func getSaleByID(req: Request) async throws -> ResponseSaleDTO {
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "ID de venta inválido")
        }
        guard let sale = try await Sale.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Venta no encontrada")
        }
        try await sale.$function.load(on: req.db)
        return try ResponseSaleDTO(sale: sale)
    }



}