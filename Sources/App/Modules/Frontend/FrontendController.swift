//
//  File.swift
//  
//
//  Created by Katherine Ebel on 11/9/20.
//

import Vapor
import Leaf

struct FrontendController {
  func homeView(_ req: Request) throws -> EventLoopFuture<View> {
    var email: String?
    if let user = req.auth.get(UserModel.self) {
      email = user.email
    }
    let context = HomeViewContext(title: "myPage - Home", header: "Hi there",
      message: "welcome to my awesome page!", isLoggedIn: email != nil, email: email)
    return req.view.render("Frontend/Home", context)
  }

  struct HomeViewContext: Encodable {
    let title: String
    let header: String
    let message: String
    let isLoggedIn: Bool
    let email: String?
  }
}

