import Fluent
import Vapor
struct CreateSale: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Sale.schema)
            .field("id", .int, .identifier(auto: true), .required)
            .field("sale_date", .datetime, .required)
            .field("username", .string, .required)
            .field("mail", .string, .required)
            .field("total", .double, .required)
            .field("number_of_seats", .int, .required)
            .field("seats_reserved", .string, .required)
            .field("qr_code", .string)
            .field("id_function", .int, .required, .references(Function.schema, "id")) 
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Sale.schema).delete()
    }
}