//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

struct UserMigrationSeed: Migration {
  func prepare(on database: Database) -> EventLoopFuture<()> {
    [
      UserModel(email: "admin@localhost.com",
        password: try! Bcrypt.hash("asuperhardpassword1"))
    ].create(on: database)
  }

  func revert(on database: Database) -> EventLoopFuture<()> {
    UserModel.query(on: database).delete()
  }
}
