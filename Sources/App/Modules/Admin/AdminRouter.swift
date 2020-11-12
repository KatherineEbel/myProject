//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor

struct AdminRouter: RouteCollection {
  let controller = AdminController()

  func boot(routes: RoutesBuilder) throws {
    routes.grouped(UserModel.sessionAuthenticator())
      .get("admin", use: controller.homeView)
  }
}
