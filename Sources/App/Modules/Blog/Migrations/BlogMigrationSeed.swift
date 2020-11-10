//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent
import LoremSwiftum

struct BlogMigrationSeed: Migration {
  func prepare(on database: Database) -> EventLoopFuture<()> {
    let categories = stride(from: 0, to: 3, by: 1).map { _ in BlogCategoryModel(title: Lorem.title) }
    return categories.create(on: database).flatMap {
      let posts = stride(from: 0, to: 10, by: 1).map { index -> BlogPostModel in
          let categoryId = categories.randomElement()!.id!
          let title = Lorem.title
          return BlogPostModel(title: title,
            slug: title.lowercased().replacingOccurrences(of: " ", with: "-"),
            image: "/images/posts/\(String(format: "%02d", index + 1)).jpg",
            excerpt: Lorem.sentence,
            date: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 60))),
            content: Lorem.paragraph,
            categoryId: categoryId)
        }.sorted() { $0.date > $1.date }
      return posts.create(on: database)
    }
  }

  func revert(on database: Database) -> EventLoopFuture<()> {
    database.eventLoop.flatten([
      BlogPostModel.query(on: database).delete(),
      BlogPostModel.query(on: database).delete()
    ])
  }
}