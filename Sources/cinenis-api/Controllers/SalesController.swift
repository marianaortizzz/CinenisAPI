import Vapor
import Fluent

struct SalesController : RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let sales = routes.grouped("sales")
        sales.get(use: getSales)
        sales.get(":saleID", use: getByID)
        sales.post(use: create)
        sales.put(":saleID", use: update)
        sales.delete(":saleID", use: delete)
    }

    func getSales(req: Request) async throws -> [SalesDTO] {
        Sale.query(on: req.db)
    }

    func getByID(req: Request) async throws -> Sale {
        guard let saleID = req.parameters.get("saleID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let sale = try await Sale.find(saleID, on: req.db) else {
            throw Abort(.notFound, reason: "Sale con ID \(saleID) no encontrado")
        }
        return sale
    }

    func create(req: Request) async throws -> Sale {
        let dto = try req.content.decode(SalesDTO.self)
        let sale = Sale(
            saleDate: dto.saleDate,
            username: dto.username,
            mail: dto.mail,
            total: dto.total,
            numberOfSeats: dto.numberOfSeats,
            seatsReserved: dto.seatsReserved,
            functionID: dto.functionID
        )
        try await sale.save(on: req.db)
        return sale
    }

    func update(req: Request) async throws -> Sale {
        guard let saleID = req.parameters.get("saleID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let dto = try req.content.decode(SalesDTO.self)
        guard let saleActual = try await Sale.find(saleID, on: req.db) else {
            throw Abort(.notFound, reason: "No existe la venta con id \(saleID)")
        }
        saleActual.saleDate = dto.saleDate
        saleActual.username = dto.username
        saleActual.mail = dto.mail
        saleActual.total = dto.total
        saleActual.numberOfSeats = dto.numberOfSeats
        saleActual.seatsReserved = dto.seatsReserved
        saleActual.$function.id = dto.functionID
        try await saleActual.save(on: req.db)
        return saleActual
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let saleID = req.parameters.get("saleID", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        guard let sale = try await Sale.find(saleID, on: req.db) else {
            throw Abort(.notFound, reason: "No existe la venta con id \(saleID)")
        }
        try await sale.delete(on: req.db)
        return .noContent
    }




}