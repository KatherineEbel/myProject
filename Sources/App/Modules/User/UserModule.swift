//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

struct UserModule: Module {
  private(set) static var name: String = "user"
  var router: RouteCollection? { UserRouter() }

  var migrations: [Migration] {
    [
      UserMigration_v1_0_0(),
      UserMigration_v1_1_0(),
      UserMigrationSeed(),
    ]
  }

  func configure(_ app: Application) throws {
    app.sessions.use(.fluent)
    app.migrations.add(SessionRecord.migration)
    app.middleware.use(app.sessions.middleware)

    migrations.forEach { migration in
      app.migrations.add(migration)
    }
    if let router = router {
      try router.boot(routes: app.routes)
    }
  }

}
