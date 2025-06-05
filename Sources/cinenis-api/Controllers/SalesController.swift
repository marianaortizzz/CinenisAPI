import Vapor
import Fluent

struct SalesController : RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        let sales = routes.grouped("sales")

        sales.get(use: self.getSales)
        
    }

    func getSales(req: Request) async throws -> [SalesDTO] {
        var salesMock : [SalesDTO] = []
        let salesDB = try await Sale.query(on: req.db).all()
        salesDB.forEach{ sale in 
            var saleDTO = SalesDTO(id: sale.id, saleDate: sale.saleDate, username: sale.username, mail: sale.mail, total: sale.total, numberOfSeats: sale.numberOfSeats, seatsReserved: sale.seatsReserved, functionID: sale.$function.id)
            salesMock.append(saleDTO)
        }
        return salesMock
    }



}