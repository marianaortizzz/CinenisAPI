import Fluent
import Vapor
struct CreateMovie: AsyncMigration {
    func prepare(on database: any  Database) async throws {
        try await database.schema(Movie.schema)
            .field("id", .int, .identifier(auto: true), .required)
            .field("title", .string, .required)
            .field("genre", .string, .required)
            .field("year", .int, .required)
            .field("director", .string, .required)
            .field("actors", .string, .required)
            .field("image", .string, .required)
            .field("description", .string, .required)
            .field("stars", .int, .required)
            .field("duration", .int, .required)
            .field("classification", .string, .required)
            .field("premiere", .bool, .required)
            .field("schedule", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Movie.schema).delete()
    }
}