import Vapor
import LeafKit
import Fluent
import FluentPostgresDriver
import Liquid
import LiquidLocalDriver

// configures your application
public func configure(_ app: Application) throws {
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  app.middleware.use(ExtendPathMiddleware())
  
  app.routes.defaultMaxBodySize = "10mb"
  
  app.fileStorages.use(.local(publicUrl: "http://localhost:8080", publicPath: app.directory.publicDirectory, workDirectory: "assets"), as: .local)
  
  
  app.databases.use(.postgres(
    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
    port: 5432,
    username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
    password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
    database: Environment.get("DATABASE_NAME") ?? "vapor_blog_dev"
  ), as: .psql)
  let detected = app.leaf.configuration.rootDirectory
  let defaultSource = NIOLeafFiles(fileio: app.fileio, limits: .default, sandboxDirectory: detected, viewDirectory: detected, defaultExtension: "html")
  let modulesSource = ModuleViewsLeafSource(rootDirectory: app.directory.workingDirectory,
    modulesLocation: "Sources/App/Modules", viewsFolderName: "Views",
    fileExtension: "html", fileIO: app.fileio)
  let leafSources = LeafSources()
  try leafSources.register(using: defaultSource)
  try leafSources.register(source: "modules", using: modulesSource)
  app.leaf.sources = leafSources
  app.views.use(.leaf)

  app.passwords.use(.bcrypt)


  if !app.environment.isRelease {
    app.leaf.cache.isEnabled = false
  }
  
  let modules: [Module] = [
    UserModule(),
    FrontendModule(),
    AdminModule(),
    BlogModule(),
    UtilityModule(),
  ]

  do {
    try modules.forEach { try $0.configure(app) }
    try app.autoMigrate().wait()
      print(app.routes.all)
  } catch {
    fatalError("Error configuring app modules")
  }

}
