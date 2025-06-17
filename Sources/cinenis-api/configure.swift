import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "db-mysql-sfo3-39177-do-user-22401106-0.l.db.ondigitalocean.com",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 25060,
        username: Environment.get("DATABASE_USERNAME") ?? "doadmin",
        password: Environment.get("DATABASE_PASSWORD") ?? "AVNS_Rxpp3bi_P88b2md3VVx",
        database: Environment.get("DATABASE_NAME") ?? "cinenis_db",
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .mysql)

    app.migrations.add(CreateMovie())
    app.migrations.add(CreateFunction())
    app.migrations.add(CreateSale())

    // register routes
    try routes(app)
}