//
// Created by Katherine Ebel on 11/12/20.
//

import Foundation
import Vapor

final class BlogPostForm: Content {
  static let validationKeys: [ValidationKey] = [.string("title"), .string("excerpt"),
                                                .string("slug"), .string("date"),
                                                .string("categoryId"), .string("content")]
  struct Inputs: Content {
    var id: String? = nil
    var title = ""
    var slug = ""
    var excerpt = ""
    var date = ""
    var content = ""
    var categoryId = ""
    var image: File?
    var imageDelete: Bool?
  }

  var id: UUID? = nil
  var title = FormField<String>(value: "")
  var slug = FormField<String>(value: "")
  var excerpt = FormField<String>(value: "")
  var date = FormField<String>(value: "")
  var content = FormField<String>(value: "")
  var category = StringSelectionFormField()
  var image = FileFormField()

  static var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
  }()

  init() {}

  convenience init(for model: BlogPostModel) {
    self.init()
    id = model.id
    title.value = model.title
    slug.value = model.slug
    excerpt.value = model.excerpt
    content.value = model.content
    date.value = BlogPostForm.dateFormatter.string(from: model.date)
    category.value = model.$category.id.uuidString
    image.value = model.image
  }

  convenience init(request: Request) {
    do {
      let inputs = try request.content.decode(BlogPostForm.Inputs.self)
      self.init(inputs: inputs)
    } catch {
      self.init()
    }
  }

  init(inputs: Inputs) {
    if let id = inputs.id {
      self.id = UUID(uuidString: id)
    }
    title.value = inputs.title
    slug.value = inputs.slug
    excerpt.value = inputs.excerpt
    date.value = inputs.date
    content.value = inputs.content
    category.value = inputs.categoryId
    image.delete = inputs.imageDelete ?? false
    if
      let img = inputs.image,
      let data = img.data.getData(at: 0, length: img.data.readableBytes),
      !data.isEmpty {
      image.data = data
    }
  }

  func write(to model: BlogPostModel) throws -> BlogPostModel {
    guard let formattedDate = BlogPostEditForm.dateFormatter.date(from: date.value) else {
      throw BlogPostError.invalidDateFormat
    }
    guard let categoryId = UUID(uuidString: category.value) else {
      throw BlogPostError.writeError(reason: "missing category id")
    }
    if model.id != nil {
      guard model.id == id else {
        throw BlogPostError.writeError(reason: "mismatching id's")
      }
    }
    model.id = id
    model.title = title.value
    model.slug = slug.value
    model.excerpt = excerpt.value
    model.date = formattedDate
    model.content = content.value
    model.$category.id = categoryId
    if !image.value.isEmpty {
      model.image = image.value
    }
    if image.delete {
      model.image = ""
    }
    return model
  }

  func withError(validationsError: ValidationsError) -> BlogPostForm {
    validationsError.failures.forEach { failure in
      let key = failure.key.stringValue
      let description = failure.result.failureDescription
      switch key {
      case "title":
        title.error = description
      case "excerpt":
        excerpt.error = description
      case "slug":
        slug.error = description
      case "date":
        date.error = description
      case "categoryId":
        category.error = description
      case "content":
        content.error = description
      default: print("unhandled failure key: '\(key)'")
      }
    }

    return self
  }
}

extension BlogPostForm.Inputs: Validatable {
  public static func validations(_ validations: inout Validations) {

    BlogPostForm.validationKeys.forEach { key in
      validations.add(key, as: String.self, is: !.empty)
    }
  }
}
