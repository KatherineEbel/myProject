//
//  File.swift
//  
//
//  Created by Katherine Ebel on 11/13/20.
//

import Vapor
import Fluent
import LeafKit

protocol ResourceController {
  associatedtype EditForm: Form
  associatedtype Model: Fluent.Model
  
  var idParamKey: String { get }
  var idPathComponent: PathComponent { get }
  var redirectURL: String { get }
  
  var listView: String { get }
  var editView: String { get }
  
  func resourceListView(req: Request) throws -> EventLoopFuture<View>
  
  
  func beforeRender(req: Request, form: EditForm) -> EventLoopFuture<Void>
  
  func render(req: Request, form: EditForm
  ) -> EventLoopFuture<View>
  
  func createResourceView(req: Request) throws -> EventLoopFuture<View>
  
  func beforeCreateResource(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
  
  func createResource(req: Request) throws -> EventLoopFuture<Response>
  
  func getResource(_ req: Request) throws -> EventLoopFuture<Model>
  
  func updateResourceView(req: Request) throws -> EventLoopFuture<View>
  
  func beforeUpdateResource(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
  
  func updateResource(req: Request) throws -> EventLoopFuture<View>
  
  func beforeDeleteResource(req: Request, model: Model) -> EventLoopFuture<Model>

  
  func deleteResource(req: Request) throws -> EventLoopFuture<String>
  
}

extension ResourceController where Model.IDValue == UUID {
  var idParamKey: String { "id" }
  var idPathComponent: PathComponent { .init(stringLiteral: ":\(idParamKey)") }
  
  func resourceListView(req: Request) throws -> EventLoopFuture<View> {
    Model.query(on: req.db).all().flatMap {
      req.view.render(listView, ["list": $0])
    }
  }

  func getResource(_ req: Request) throws -> EventLoopFuture<Model> {
    guard let id = req.parameters.get(idParamKey),
          let uuid = UUID(uuidString: id) else {
      throw Abort(.badRequest)
    }
    return Model.find(uuid, on: req.db)
      .unwrap(or: Abort(.notFound))
  }

  func beforeRender(req: Request, form: EditForm) -> EventLoopFuture<Void> {
    req.eventLoop.future()
  }

  func render(req: Request, form: EditForm) -> EventLoopFuture<View> {
    beforeRender(req: req, form: form).flatMap {
      req.view.render(editView, ["form": form])
    }
  }

  func createResourceView(req: Request) throws -> EventLoopFuture<View> {
    render(req: req, form: .init())
  }

  func beforeCreateResource(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
    req.eventLoop.future(model)
  }

  func createResource(req: Request) throws -> EventLoopFuture<Response> {
    let form = try EditForm(req: req)
    do {
      try EditForm.Input.validate(content: req)
      let model = Model()
      form.write(to: model as! EditForm.Model)
      return beforeCreateResource(req: req, model: model, form: form)
        .flatMap { model in
          model.create(on: req.db).map { req.redirect(to: redirectURL) }
        }
    } catch let error as ValidationsError {
      _ = error.failures.map { print($0) }
      return render(req: req, form: form).encodeResponse(for: req)
    }
  }

  func updateResourceView(req: Request) throws -> EventLoopFuture<View> {
    try getResource(req).flatMap { model in
      let form = EditForm()
      form.read(from: model as! EditForm.Model)
      return render(req: req, form: form)
    }
  }

  func beforeUpdateResource(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
    req.eventLoop.future(model)
  }

  func updateResource(req: Request) throws -> EventLoopFuture<View> {
    let form = try EditForm(req: req)
    do {
      try EditForm.Input.validate(content: req)
      return try getResource(req)
        .flatMap { beforeUpdateResource(req: req, model: $0, form: form) }
        .flatMap { model in
          form.write(to: model as! EditForm.Model)
          return model.update(on: req.db)
            .map { form.read(from: model as! EditForm.Model) }
        }
        .flatMap { render(req: req, form: form) }
    } catch  {
      return req.eventLoop.future(error: error)
    }
  }

  func beforeDeleteResource(req: Request, model: Model) -> EventLoopFuture<Model> {
    req.eventLoop.future(model)
  }

  func deleteResource(req: Request) throws -> EventLoopFuture<String> {
    try getResource(req)
      .flatMap { beforeDeleteResource(req: req, model: $0) }
      .flatMap { model in
        model.delete(on: req.db)
          .map { model.id!.uuidString }
      }
  }
}
