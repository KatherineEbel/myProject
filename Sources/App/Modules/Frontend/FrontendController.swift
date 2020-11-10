//
//  File.swift
//  
//
//  Created by Katherine Ebel on 11/9/20.
//

import Vapor
import Leaf

struct FrontendController {
  func homeView(_ req: Request) -> EventLoopFuture<View> {
    req.view.render("home", [
      "title": "myPage - Home",
      "header": "Hi there,",
      "message": "welcome to my awesome page!"
    ])
  }

}

