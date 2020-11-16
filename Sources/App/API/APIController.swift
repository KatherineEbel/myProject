//
// Created by Katherine Ebel on 11/16/20.
//

import Vapor

protocol APIController: ListContentController,
  GetContentController,
  CreateContentController,
  UpdateContentController,
  PatchContentController,
  DeleteContentController {

  func setupRoutes(routes: RoutesBuilder, on pathComponent: PathComponent)
}

extension APIController {
  func setupRoutes(routes: RoutesBuilder, on pathComponent: PathComponent) {
    let modelRoutes = routes.grouped(pathComponent)
    setupListRoute(routes: modelRoutes)
    setupGetRoute(routes: modelRoutes)
    setupCreateRoute(routes: modelRoutes)
    setupUpdateRoute(routes: modelRoutes)
    setupPatchRoute(routes: modelRoutes)
    setupDeleteRoute(routes: modelRoutes)
  }
}
