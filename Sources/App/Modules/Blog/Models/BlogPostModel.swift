//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

enum BlogPostError: Error {
  case writeError(reason: String)
  case readError(reason: String)
  case invalidDateFormat
}
final class BlogPostModel: Model {
  static let schema: String = "blog_posts"

  struct FieldKeys {
    static var title: FieldKey { "title" }
    static var slug: FieldKey { "slug" }
    static var image: FieldKey { "image" }
    static var imageKey: FieldKey { "image_key" }
    static var excerpt: FieldKey { "excerpt" }
    static var date: FieldKey { "date" }
    static var content: FieldKey { "content" }
    static var categoryId: FieldKey { "category_id" }
  }

  @ID() var id: UUID?
  @Field(key: FieldKeys.title) var title: String
  @Field(key: FieldKeys.slug) var slug: String
  @Field(key: FieldKeys.image) var image: String
  @Field(key: FieldKeys.imageKey) var imageKey: String?
  @Field(key: FieldKeys.excerpt) var excerpt: String
  @Field(key: FieldKeys.date) var date: Date
  @Field(key: FieldKeys.content) var content: String
  @Parent(key: FieldKeys.categoryId) var category: BlogCategoryModel

  init() {}

  init(id: UUID? = nil,
       title: String,
       slug: String,
       image: String,
       imageKey: String? = nil,
       excerpt: String,
       date: Date,
       content: String,
       categoryId: UUID) {
    self.id = id
    self.title = title
    self.slug = slug
    self.image = image
    self.imageKey = imageKey
    self.excerpt = excerpt
    self.date = date
    self.content = content
    $category.id = categoryId
  }

  static func edit(from request: Request) throws -> EventLoopFuture<BlogPostModel?> {
      let context = try request.content.decode(BlogPostEditForm.self)
      let uuid: UUID? = context.id != nil ? UUID(context.id!) : nil
      return BlogPostModel.find(uuid, on: request.db).flatMap { blogPost in
        let uuid = UUID(uuidString: context.categoryId)
        return BlogCategoryModel.find(uuid, on: request.db)
          .unwrap(or: Abort(.badRequest))
          .map { category in
            category.id
          }
          .unwrap(or: Abort(.internalServerError))
          .flatMap { id in
            context.write(to: blogPost, with: id, for: request)
          }
          .flatMap { model in
            if let model = model {
              return model.save(on: request.db).map { model }
            } else {
              return request.eventLoop.future(nil)
            }
          }
      }
  }
}