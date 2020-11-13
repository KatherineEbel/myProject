//
// Created by Katherine Ebel on 11/13/20.
//

import Foundation
import Vapor
import Fluent

final class BlogCategoryForm: Content {
  struct Input: Content {
    var id: String
    var title: String
  }

  var id: String? = nil
  var title = FormField<String>(value: "")

  init() {}

  init(req: Request) throws {
    let context = try req.content.decode(Input.self)
    if !context.id.isEmpty {
      id = context.id
    }
    title.value = context.title
  }

  func read(from model: BlogCategoryModel) {
    if let id = model.id {
      self.id = id.uuidString
    }
    self.title.value = model.title
  }

  func write(to model: BlogCategoryModel) {
    model.title = title.value
  }
}

extension BlogCategoryForm.Input: Validatable {
  public static func validations(_ validations: inout Validations) {
    validations.add("title", as: String.self, is: !.empty)
  }
}
