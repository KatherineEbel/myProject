//
// Created by Katherine Ebel on 11/16/20.
//

import Fluent

struct UserMigration_v1_1_0: Migration {
  func prepare(on database: Database) -> EventLoopFuture<()> {
    database.schema(UserTokenModel.schema)
      .id()
      .field(UserTokenModel.FieldKeys.value, .string, .required)
      .field(UserTokenModel.FieldKeys.userId, .uuid, .required)
      .foreignKey(UserTokenModel.FieldKeys.userId, references: UserModel.schema, .id)
      .unique(on: UserTokenModel.FieldKeys.value)
      .create()

  }

  func revert(on database: Database) -> EventLoopFuture<()> {
    database.schema(UserTokenModel.schema)
      .delete()
  }
}
