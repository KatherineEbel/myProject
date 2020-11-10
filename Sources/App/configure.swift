import Vapor
import Leaf
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  app.middleware.use(ExtendPathMiddleware())
  app.databases.use(.postgres(
    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
    port: 5432,
    username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
    password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
    database: Environment.get("DATABASE_NAME") ?? "vapor_blog_dev"
  ), as: .psql)
  let detected = app.leaf.configuration.rootDirectory
  app.leaf.sources = .singleSource(NIOLeafFiles(fileio: app.fileio, limits: .default, sandboxDirectory: detected, viewDirectory: detected, defaultExtension: "html"))

  if !app.environment.isRelease {
    app.leaf.cache.isEnabled = false
  }
  
  app.views.use(.leaf)

  let modules: [Module] = [
    FrontendModule(),
    BlogModule(),
  ]

  do {
    try modules.forEach { try $0.configure(app) }
    try app.autoMigrate().wait()
  } catch {
    fatalError("Error configuring app modules")
  }

}
