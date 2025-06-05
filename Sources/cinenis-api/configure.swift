import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor


func loadEnvFile() {
    let envPath = FileManager.default.currentDirectoryPath + "/.env"
    guard let content = try? String(contentsOfFile: envPath) else { return }

    content
        .split(separator: "\n")
        .map { $0.split(separator: "=", maxSplits: 1) }
        .forEach { pair in
            guard pair.count == 2 else { return }
            let key = String(pair[0])
            let value = String(pair[1])
            setenv(key, value, 1)
        }
}


// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    loadEnvFile()


app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 3306,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "cinenis",
        tlsConfiguration: .forClient(certificateVerification: .none)
    ), as: .mysql)

    app.migrations.add(CreateMovie())
    app.migrations.add(CreateFunction())
    app.migrations.add(CreateSale())

    // register routes
    try routes(app)
}