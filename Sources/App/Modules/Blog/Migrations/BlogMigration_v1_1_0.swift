//
// Created by Katherine Ebel on 11/10/20.
//

import Foundation
import Fluent

struct BlogMigration_v1_1_0: Migration {
  func prepare(on database: Database) -> EventLoopFuture<()> {
    database.schema(BlogPostModel.schema)
      .field(BlogPostModel.FieldKeys.imageKey, .string)
      .update()
  }

  func revert(on database: Database) -> EventLoopFuture<()> {
    database.schema(BlogPostModel.schema)
      .deleteField(BlogPostModel.FieldKeys.imageKey)
      .update()

  }
}