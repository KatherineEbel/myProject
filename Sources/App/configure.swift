import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  app.middleware.use(ExtendPathMiddleware())
  
  let detected = app.leaf.configuration.rootDirectory
  app.leaf.sources = .singleSource(NIOLeafFiles(fileio: app.fileio, limits: .default, sandboxDirectory: detected, viewDirectory: detected, defaultExtension: "html"))

  if !app.environment.isRelease {
    app.leaf.cache.isEnabled = false
  }
  
  app.views.use(.leaf)

  let routers: [RouteCollection] = [
    FrontendRouter(),
    BlogRouter(),
  ]
  do {
    try routers.forEach { try $0.boot(routes: app.routes) }
  } catch {
    fatalError("Error booting routers")
  }
}
