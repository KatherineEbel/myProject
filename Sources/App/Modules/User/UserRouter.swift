//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor

struct UserRouter: RouteCollection {
  let controller = UserFrontendController()

  func boot(routes: RoutesBuilder) throws {
    routes.get("sign-in", use: controller.loginView)
    let signInRoutes = routes.grouped(UserModelCredentialsAuthenticator())
    signInRoutes.post("sign-in", use: controller.login)
    routes.grouped(UserModel.sessionAuthenticator())
      .get("logout", use: controller.logout)
  }
}
