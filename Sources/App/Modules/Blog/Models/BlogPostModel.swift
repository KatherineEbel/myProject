//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

final class BlogPostModel: Model {
  static let schema: String = "blog_posts"

  struct FieldKeys {
    static var title: FieldKey { "title" }
    static var slug: FieldKey { "slug" }
    static var image: FieldKey { "image" }
    static var excerpt: FieldKey { "excerpt" }
    static var date: FieldKey { "date" }
    static var content: FieldKey { "content" }
    static var categoryId: FieldKey { "category_id" }
  }

  @ID() var id: UUID?
  @Field(key: FieldKeys.title) var title: String
  @Field(key: FieldKeys.slug) var slug: String
  @Field(key: FieldKeys.image) var image: String
  @Field(key: FieldKeys.excerpt) var excerpt: String
  @Field(key: FieldKeys.date) var date: Date
  @Field(key: FieldKeys.content) var content: String
  @Parent(key: FieldKeys.categoryId) var category: BlogCategoryModel

  init() {}

  init(id: UUID? = nil,
       title: String,
       slug: String,
       image: String,
       excerpt: String,
       date: Date,
       content: String,
       categoryId: UUID) {
    self.id = id
    self.title = title
    self.slug = slug
    self.image = image
    self.excerpt = excerpt
    self.date = date
    self.content = content
    $category.id = categoryId
  }

  static func edit(from request: Request) throws -> EventLoopFuture<BlogPostModel?> {
      let context = try request.content.decode(BlogPostEditForm.self)
      let uuid: UUID? = context.id != nil ? UUID(context.id!) : nil
      return BlogPostModel.find(uuid, on: request.db).flatMap { blogPost in
        BlogCategoryModel.query(on: request.db).first()
          .unwrap(or: Abort(.notFound))
          .map { category in
            category.id
          }
          .unwrap(or: Abort(.internalServerError))
          .flatMap { id in
            if let updatedBlogpost = context.write(to: blogPost, with: id) {
              return updatedBlogpost.save(on: request.db).map { updatedBlogpost }
            } else {
              return request.eventLoop.future(nil)
            }
          }
      }
  }
}
//if let error = error as? DecodingError {
//  switch error {
//  case .typeMismatch(let key, let value):
//    print("TYPE MISMATCH")
//    print("error '\(key)', value '\(value)' and ERROR: '\(error.localizedDescription)'")
//  case .valueNotFound(let key, let value):
//    print("VALUE NOT FOUND")
//    print("error '\(key)', value '\(value)' and ERROR: '\(error.localizedDescription)'")
//  case .keyNotFound(let key, let value):
//    print("KEY NOT FOUND")
//    print("error '\(key)', value '\(value)' and ERROR: '\(error.localizedDescription)'")
//  case .dataCorrupted(let key):
//    print("DATA CORRUPTED")
//    print("error '\(key)', and ERROR: '\(error.localizedDescription)'")
//  default:
//    print("ERROR: '\(error.localizedDescription)'")
//  }
//} else {
//  print("ERROR: ", error.localizedDescription)
//}
//throw error
