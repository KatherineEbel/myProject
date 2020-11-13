//
// Created by Katherine Ebel on 11/10/20.
//

import Foundation
import Vapor
import Fluent

struct BlogModule: Module {
  var router: RouteCollection? { BlogRouter() }
  var migrations: [Migration] {
    [
      BlogMigration_v1_0_0(),
      BlogMigrationSeed(),
      BlogMigration_v1_1_0(),
    ]
  }
}
