import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("secrets.DATABASE_HOST") ?? "",
        port: Environment.get("secrets.DATABASE_PORT").flatMap(Int.init(_:)) ?? 25060,
        username: Environment.get("secrets.DATABASE_USERNAME") ?? "",
        password: Environment.get("secrets.DATABASE_PASSWORD") ?? "",
        database: Environment.get("secrets.DATABASE_NAME") ?? "",
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .mysql)

    app.migrations.add(CreateMovie())
    app.migrations.add(CreateFunction())
    // app.migrations.add(CreateSale())

    // register routes
    try routes(app)
    try app.register(collection: MovieController())
}