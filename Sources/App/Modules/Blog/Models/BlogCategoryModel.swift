//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

final class BlogCategoryModel: Model {
  static let schema = "blog_categories"

  struct FieldKeys {
    static var title: FieldKey { "title" }
  }

  @ID() var id: UUID?
  @Field(key: FieldKeys.title) var title: String
  @Children(for: \.$category) var posts: [BlogPostModel]

  init() {}

  init(id: UUID? = nil, title: String) {
    self.id = id
    self.title = title
  }
}

extension BlogCategoryModel: FormFieldStringOptionRepresentable {
  var formFieldStringOption: FormFieldStringOption {
    .init(key: id!.uuidString, label: title)
  }

}
