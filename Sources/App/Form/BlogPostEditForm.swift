//
//  BlogPostEditForm.swift
//
//
//  Created by Katherine Ebel on 11/10/20.
//

import Foundation
import Vapor
import Leaf

final class BlogPostEditForm: Content {
  var id: String? = nil
  var title = ""
  var slug = ""
  var excerpt = ""
  var date = ""
  var content = ""

  static var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  private static func fromModel(_ model: BlogPostModel) throws -> BlogPostEditForm {
    if !model._$id.exists {
      return BlogPostEditForm()
    }
    let form = BlogPostEditForm(id: try model.requireID().uuidString)
    form.title = model.title
    form.slug = model.slug
    form.excerpt = model.excerpt
    form.date = dateFormatter.string(from: model.date)
    form.content = model.content
    print(form.date)
    return form

  }

  static func fromRequest(_ req: Request) throws -> EventLoopFuture<BlogPostEditForm> {
    BlogPostModel.find(req.parameters.get("id"), on: req.db)
      .unwrap(orReplace: BlogPostModel())
      .flatMapThrowing(fromModel)
  }

  init(id: String? = nil) {
    self.id = id
    self.title = ""
    self.slug = ""
    self.excerpt = ""
    self.content = ""
    self.date = ""
  }

  func write(to model: BlogPostModel?, with categoryID: UUID) -> BlogPostModel? {
    let updatedModel = model ?? BlogPostModel()
    guard let formattedDate = BlogPostEditForm.dateFormatter.date(from: date) else {
      return nil
    }
    updatedModel.$category.id = categoryID
    updatedModel.title = title
    updatedModel.slug = slug
    updatedModel.excerpt = excerpt
    updatedModel.date = formattedDate
    updatedModel.content = content
    updatedModel.image = "/images/posts/01.jpg" // TODO: don't hardcode image
    return updatedModel
  }
}

extension BlogPostEditForm: Validatable {
  public class func validations(_ validations: inout Validations) {
    validations.add("title", as: String.self, is: !.empty)
    validations.add("excerpt", as: String.self, is: !.empty)
    validations.add("slug", as: String.self, is: !.empty)
    validations.add("date", as: String.self, is: !.empty)
    validations.add("content", as: String.self, is: !.empty)
  }

}

