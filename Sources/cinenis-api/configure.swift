import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST"),
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)),
        username: Environment.get("DATABASE_USERNAME"),
        password: Environment.get("DATABASE_PASSWORD") ,
        database: Environment.get("DATABASE_NAME"),
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .mysql)

    app.migrations.add(CreateMovie())
    app.migrations.add(CreateFunction())
    app.migrations.add(CreateSale())

    // register routes
    try routes(app)
}
