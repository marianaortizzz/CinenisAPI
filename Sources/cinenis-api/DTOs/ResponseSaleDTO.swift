import Vapor
import Foundation

struct ResponseSaleDTO : Content {
    var id: Int?
    var saleDate : Date
    var username : String
    var mail : String
    var total : Double
    var numberOfSeats : Int
    var seatsReserved : String
    var functionID: Int

    init(sale: Sale) throws {
        self.id = sale.id
        self.saleDate = sale.saleDate
        self.username = sale.username
        self.mail = sale.mail
        self.total = sale.total
        self.numberOfSeats = sale.numberOfSeats
        self.seatsReserved = sale.seatsReserved
        self.functionID = sale.$function.id
        // si cargaste la relación con `.with(\.$function)`, también podrías exponer más campos de Function aquí
    }

}