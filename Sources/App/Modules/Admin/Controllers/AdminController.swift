//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Leaf

struct AdminController {
  func homeView(req: Request) throws -> EventLoopFuture<View> {
    let user = try req.auth.require(UserModel.self)
    return req.view.render("Admin/Home", [
      "header": "Hi \(user.email)",
      "message": "welcome to the CMS!",
    ])
  }
}
