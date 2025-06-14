import Vapor
import Fluent


struct SalesController : RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        let sales = routes.grouped("sales")

        sales.get(use: self.getSales)
        sales.post(use: self.create)
        sales.get(":id", use: self.getSaleByID)
        sales.put(":id", use: self.update)
        sales.delete(":id", use: delete)    
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
            qrCode: dto.qrCode,
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

    func update(req: Request) async throws -> ResponseSaleDTO {
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "ID de venta inválido")
        }
        let dto = try req.content.decode(CreateSaleDTO.self)
        guard let sale = try await Sale.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Venta no encontrada")
        }
        sale.saleDate = dto.saleDate
        sale.username = dto.username
        sale.mail = dto.mail
        sale.total = dto.total
        sale.numberOfSeats = dto.numberOfSeats
        sale.seatsReserved = dto.seatsReserved
        sale.$function.id = dto.functionID
        try await sale.save(on: req.db)
        try await sale.$function.load(on: req.db)
        return try ResponseSaleDTO(sale: sale)
    }

    func delete(req: Request) async throws -> ResponseSaleDTO {
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest, reason: "ID de venta inválido")
        }
        guard let sale = try await Sale.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Venta no encontrada")
        }
        try await sale.$function.load(on: req.db)
        let deletedDTO = try ResponseSaleDTO(sale: sale)
        try await sale.delete(on: req.db)
        return deletedDTO
    }

    private func generateBase64QR(from dto: ResponseSaleDTO) throws -> String {
    let json = try JSONEncoder().encode(dto)
    let text = String(decoding: json, as: UTF8.self)
    // URL-encode
    guard let escaped = text.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
        throw Abort(.internalServerError)
    }
    // Google Charts QR API
    let urlString = "https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=\(escaped)"
    guard let url = URL(string: urlString),
            let data = try? Data(contentsOf: url)
    else {
        throw Abort(.internalServerError, reason: "No se obtuvo imagen de QR")
    }
    return data.base64EncodedString()
    }
}