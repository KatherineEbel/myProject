//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

struct UserMigration_v1_0_0: Migration {
  func prepare(on database: Database) -> EventLoopFuture<()> {
    database.schema(UserModel.schema)
    .id()
    .field(UserModel.FieldKeys.email, .string, .required)
    .field(UserModel.FieldKeys.password, .string, .required)
    .unique(on: UserModel.FieldKeys.email)
    .create()
  }

  func revert(on database: Database) -> EventLoopFuture<()> {
    database.schema(UserModel.schema).delete()
  }
}
