//
// Created by Katherine Ebel on 11/13/20.
//

import Vapor
import Fluent
import LeafKit

struct BlogCategoryAdminController {
  func listView(_ req: Request) throws -> EventLoopFuture<View> {
    BlogCategoryModel.query(on: req.db)
      .all()
      .flatMap {
        req.view.render("Blog/Admin/Categories/List", ["list": $0])
      }
  }
  
  func beforeRender(req: Request, form: BlogCategoryForm) -> EventLoopFuture<Void> {
    req.eventLoop.future()
  }
  
  func render(req: Request, form: BlogCategoryForm) -> EventLoopFuture<View> {
    beforeRender(req: req, form: form).flatMap {
      req.view.render("Blog/Admin/Categories/Edit", ["form": form])
    }
  }
  
  func createView(req: Request) throws -> EventLoopFuture<View> {
    render(req: req, form: .init())
  }
  
  func beforeCreate(req: Request, model: BlogCategoryModel, form: BlogCategoryForm) -> EventLoopFuture<BlogCategoryModel> {
    req.eventLoop.future(model)
  }
  
  func create(_ req: Request) throws -> EventLoopFuture<Response> {
    var form = BlogCategoryForm()
    do {
      form = try BlogCategoryForm(req: req)
      try BlogCategoryForm.Input.validate(content: req)
      let model = BlogCategoryModel()
      form.write(to: model)
      return beforeCreate(req: req, model: model, form: form)
        .flatMap { model in
          model.create(on: req.db).map { req.redirect(to: "/admin/blog/categories") }
        }
    } catch let error as ValidationsError {
      _ = error.failures.map { print($0) }
      return render(req: req, form: form).encodeResponse(for: req)
    }
  }
  
  func find(_ req: Request) throws -> EventLoopFuture<BlogCategoryModel> {
    guard let id = req.parameters.get("id"),
          let uuid = UUID(uuidString: id) else {
      throw Abort(.badRequest)
    }
    return BlogCategoryModel.find(uuid, on: req.db).unwrap(or: Abort(.notFound))
  }
  
  func updateView(_ req: Request) throws -> EventLoopFuture<View> {
    try find(req).flatMap { model in
      let form = BlogCategoryForm()
      form.read(from: model)
      return render(req: req, form: form)
    }
  }
  
  func beforeUpdate(req: Request, model: BlogCategoryModel) -> EventLoopFuture<BlogCategoryModel> {
    req.eventLoop.future(model)
  }
  
  func update(_ req: Request) throws -> EventLoopFuture<View> {
    let form = try BlogCategoryForm(req: req)
    do {
      try BlogCategoryForm.Input.validate(content: req)
      return try find(req)
        .flatMap { beforeUpdate(req: req, model: $0) }
        .flatMap { model in
          form.write(to: model)
          return model.update(on: req.db)
            .map { form.read(from: model) }
        }
        .flatMap { render(req: req, form: form) }
    } catch  {
      return req.eventLoop.future(error: error)
    }
  }
  
  func beforeDelete(req: Request, model: BlogCategoryModel) -> EventLoopFuture<BlogCategoryModel> {
    req.eventLoop.future(model)
  }
  
  func delete(_ req: Request) throws -> EventLoopFuture<String> {
    try find(req)
      .flatMap { beforeDelete(req: req, model: $0) }
      .flatMap { model in model.delete(on: req.db).map { model.id!.uuidString } }
  }
}
