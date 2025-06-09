import Fluent
import Vapor
struct CreateFunction: AsyncMigration {
    func prepare(on database: any  Database) async throws {
        try await database.schema(Function.schema)
            .field("id", .int, .identifier(auto: true), .required)
            .field("function_date", .datetime, .required)
            .field("room", .int, .required)
            .field("availability", .string, .required)
            .field("id_movie", .int, .required, .references(Movie.schema, "id"))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Function.schema).delete()
    }
}