//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent
import Leaf

struct BlogPostAdminController {
  func listView(_ req: Request) throws -> EventLoopFuture<View> {
    BlogPostModel.query(on: req.db).all()
      .flatMap {
      req.view.render("Blog/Admin/Posts/List", ListViewContext(title: "Blog Admin", list: $0))
    }
  }

  func createView(_ req: Request) throws -> EventLoopFuture<View> {
    req.session.data["postError"] = nil
    return try BlogPostEditForm.fromRequest(req)
      .flatMapErrorThrowing { error in
        req.session.data["postError"] = error.localizedDescription
        return BlogPostEditForm()
      }
      .flatMap { form in
        let error = req.session.data["postError"]
        return BlogCategoryModel.query(on: req.db)
          .all()
          .flatMap { categories in
            let options = categories.map { category in FormFieldStringOption.fromModel(category)}
            return req.view.render("Blog/Admin/Posts/Edit", CreateViewContext(title: "Blog Admin", edit: form, editMode: "Create", errors: error, categories: options))
        }
      }
  }

  func createPost(_ req: Request) throws -> EventLoopFuture<Response> {
    try req.auth.require(UserModel.self)
    do {
      try BlogPostEditForm.validate(content: req)
    } catch {
      if let error = error as? ValidationsError {
        req.session.data["postError"] = error.description
        return req.eventLoop.future(req.redirect(to: "/admin/blog/posts"))
      }
      print(error.localizedDescription)
    }
    return try BlogPostModel.edit(from: req).map { post in
      if post != nil {
        return req.redirect(to: "/admin/blog/posts")
      } else {
        return req.redirect(to: "/admin/blog/posts/new")
      }
    }
  }

  func delete(_ req: Request) throws -> EventLoopFuture<Response> {
    try req.auth.require(UserModel.self)
    return BlogPostModel.find(req.parameters.get("id"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap {
        $0.delete(on: req.db)
      }
      .map {
        req.redirect(to: "/admin/blog/posts")
      }
  }
  struct ListViewContext: Encodable {
    let title: String
    let list: [BlogPostModel]
  }

  struct CreateViewContext: Content {
    let title: String
    let edit: BlogPostEditForm
    let editMode: String
    let errors: String?
    let categories: [FormFieldStringOption]
  }
}