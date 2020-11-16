//
// Created by Katherine Ebel on 11/15/20.
//

import Vapor
import Fluent

protocol ListContentController: ContentController where Model: ListContentRepresentable {
  func list(_: Request) throws -> EventLoopFuture<Page<Model.ListItem>>
  func setupListRoute(routes: RoutesBuilder)
}

extension ListContentController {
  func list(_ request: Request) throws -> EventLoopFuture<Page<Model.ListItem>> {
    Model.query(on: request.db).paginate(for: request).map { $0.map(\.listContent) }
  }

  func setupListRoute(routes: RoutesBuilder) {
    routes.get(use: list)
  }
}
