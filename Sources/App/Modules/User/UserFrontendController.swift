//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent
import Leaf


struct UserFrontendController {
  func loginView(_ req: Request) throws -> EventLoopFuture<View> {
    req.view.render("User/Frontend/Login", LoginViewContext(title: "myPage - Sign in"))
  }

  func login(_ req: Request) throws -> Response {
    guard let user = req.auth.get(UserModel.self) else {
      throw Abort(.unauthorized)
    }
    req.session.authenticate(user)
    return req.redirect(to: "/")
  }

  func logout(_ req: Request) throws -> Response {
    req.auth.logout(UserModel.self)
    req.session.unauthenticate(UserModel.self)
    return req.redirect(to: "/")
  }

  struct LoginViewContext: Encodable {
    let title: String
  }
}
