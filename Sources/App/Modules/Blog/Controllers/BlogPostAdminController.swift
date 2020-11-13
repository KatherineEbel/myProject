//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent
import Leaf
import Liquid

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

  func create(_ req: Request) throws -> EventLoopFuture<Response> {
    var form: BlogPostForm
    do {
      form = BlogPostForm(request: req)
      try BlogPostForm.Inputs.validate(content: req)
      if form.id != nil {
        return BlogPostModel.find(form.id, on: req.db)
          .unwrap(or: Abort(.notFound))
          .flatMapThrowing { try form.write(to: $0) }
          .flatMap { model in
            beforeUpdate(req: req, model: model, form: form)
              .flatMap { $0.update(on: req.db) }
          }
          .map { req.redirect(to: "/admin/blog/posts")}
      }
      let model = try form.write(to: BlogPostModel())
      return beforeCreate(req: req, model: model, form: form)
        .flatMap { $0.save(on: req.db) }
        .map { req.redirect(to: "/admin/blog/posts/") }
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
    return BlogPostModel.find(req.parameters.get("id"), on: req.db)
      .unwrap(or: Abort(.notFound))
      .flatMap { model in beforeDelete(req: req, model: model) }
      .flatMap { $0.delete(on: req.db) }
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

  private func beforeCreate(req: Request, model: BlogPostModel, form: BlogPostForm) -> EventLoopFuture<BlogPostModel> {
    var future: EventLoopFuture<BlogPostModel> = req.eventLoop.future(model)
    if let data = form.image.data {
      let key = "/blog/posts/" + UUID().uuidString + ".jpg"
      future = req.fs.upload(key: key, data: data).map { url in
        form.image.value = url
        model.imageKey = key
        model.image = url
        return model
      }
    }
    return future
  }
  
  private func beforeUpdate(req: Request, model: BlogPostModel, form: BlogPostForm) -> EventLoopFuture<BlogPostModel> {
    var future: EventLoopFuture<BlogPostModel> = req.eventLoop.future(model)
    if (form.image.delete || form.image.data != nil), let imageKey = model.imageKey {
      future = req.fs.delete(key: imageKey).map {
        form.image.value = ""
        model.image = ""
        model.imageKey = nil
        return model
      }
    }
    if let data = form.image.data {
      return future.flatMap { model in
        let key = "/blog/posts/" + UUID().uuidString + ".jpg"
        return req.fs.upload(key: key, data: data).map { url in
          form.image.value = url
          model.imageKey = key
          model.image = url
          return model
        }
      }
    }
    return future
  }

  private func beforeDelete(req: Request, model: BlogPostModel) -> EventLoopFuture<BlogPostModel> {
    if let key = model.imageKey {
      return req.fs.delete(key: key).map { model }
    }
    return req.eventLoop.future(model)
  }
  
  struct ListViewContext: Encodable {
    let title: String
    let list: [BlogPostModel]
  }
}
