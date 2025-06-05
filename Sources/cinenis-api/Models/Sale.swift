import Fluent
import Vapor

final class Sale: Model, Content, @unchecked Sendable {
    static let schema = "sale" 
    @ID(custom: "id", generatedBy: .database)
    var id: Int?

    @Field(key: "sale_date")
    var saleDate: Date

    @Field(key: "username")
    var username: String

    @Field(key: "mail")
    var mail: String

    @Field(key: "total")
    var total: Double 

    @Field(key: "number_of_seats")
    var numberOfSeats: Int

    @Field(key: "seats_reserved")
    var seatsReserved: String 

    
    @Parent(key: "id_function")
    var function: Function

    nonisolated(unsafe) init() { }

    nonisolated(unsafe) init(id: Int? = nil, saleDate: Date, username: String, mail: String, total: Double, numberOfSeats: Int, seatsReserved: String, functionID: Function.IDValue) {
        self.id = id
        self.saleDate = saleDate
        self.username = username
        self.mail = mail
        self.total = total
        self.numberOfSeats = numberOfSeats
        self.seatsReserved = seatsReserved
        self.$function.id = functionID 
    }
}