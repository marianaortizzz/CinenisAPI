import Vapor
import Foundation

struct SalesDTO : Content {
    var id : UUID?
    var saleDate : Date
    var username : String
    var mail : String
    var total : Double
    var numberOfSeats : Int
    var seatsReserved : String
    var functionID: UUID
}