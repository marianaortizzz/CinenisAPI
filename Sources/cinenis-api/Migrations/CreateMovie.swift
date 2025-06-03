import Fluent
import Vapor
struct CreateMovie: AsyncMigration {
    func prepare(on database: any  Database) async throws {
        try await database.schema(Movie.schema)
            .id()
            .field("title", .string, .required)
            .field("genre", .string, .required)
            .field("year", .int, .required)
            .field("image", .string, .required)
            .field("description", .string, .required)
            .field("stars", .int, .required)
            .field("duration", .int, .required)
            .field("classification", .string, .required)
            .field("schedule", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Movie.schema).delete()
    }
}