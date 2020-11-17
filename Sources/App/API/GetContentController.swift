//
// Created by Katherine Ebel on 11/16/20.
//

import Vapor
import Fluent

protocol GetContentController: IdentifiableContentController where Model: GetContentRepresentable {
  func get(_: Request) throws -> EventLoopFuture<Model.GetContent>
  func setupGetRoute(routes: RoutesBuilder)
}

extension GetContentController {
  func get(_ request: Request) throws -> EventLoopFuture<Model.GetContent> {
    try find(request).map(\.getContent)
  }

  func setupGetRoute(routes: RoutesBuilder) {
    routes.get(idPathComponent, use: get)
  }
}
