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
    if let _ = req.parameters.get("id") {
      return try updateView(req)
    }
    return beforeRenderCreate(req: req, form: BlogPostForm())
      .flatMap { form in
        req.view.render("Blog/Admin/Posts/Edit",["form": form])
      }
  }

  func createPost(_ req: Request) throws -> EventLoopFuture<Response> {
    var form: BlogPostForm
    do {
      form = BlogPostForm(request: req)
      try BlogPostForm.Inputs.validate(content: req)
      let model = try form.write(to: BlogPostModel())
      if model.id != nil {
        return model.update(on: req.db).map {
          req.redirect(to: "/admin/blog/posts")
        }
      }
      return model.save(on: req.db).map {
        req.redirect(to: "/admin/blog/posts")
      }
    } catch let error as ValidationsError {
      print(error.description)
      let formWithError = form.withError(validationsError: error)
      return beforeRenderCreate(req: req, form: formWithError).flatMap { options in
        req.view
          .render("Blog/Admin/Posts/Edit", ["form": formWithError])
          .encodeResponse(for: req)
      }
    } catch let error as BlogPostError {
      switch error {
      case .writeError(let reason): print(reason)
      case .invalidDateFormat: print("Invalid date format")
      case .readError: print("Not handled yet")
      }
      return beforeRenderCreate(req: req, form: form)
        .flatMap {
          req.view.render("Blog/Admin/Posts/Edit", ["form": $0]).encodeResponse(for: req)
        }
    }
  }

  func updateView(_ req: Request) throws -> EventLoopFuture<View> {
    BlogPostModel.find(req.parameters.get("id"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { model in
        let form = BlogPostForm(for: model)
        return beforeRenderCreate(req: req, form: form)
          .flatMap { req.view.render("Blog/Admin/Posts/Edit", ["form": $0]) }
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

  private func beforeRenderCreate(req: Request, form: BlogPostForm) -> EventLoopFuture<BlogPostForm> {
    BlogCategoryModel.query(on: req.db)
      .all()
      .mapEach(\.formFieldStringOption)
      .map { form.category.options = $0}
      .map { form }
  }

  struct ListViewContext: Encodable {
    let title: String
    let list: [BlogPostModel]
  }
}