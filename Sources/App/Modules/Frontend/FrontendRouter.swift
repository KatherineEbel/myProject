//
//  File.swift
//  
//
//  Created by Katherine Ebel on 11/9/20.
//

import Vapor

struct FrontendRouter: RouteCollection {
  let controller = FrontendController()
  
  func boot(routes: RoutesBuilder) throws {
    routes.get(use: controller.homeView)
  }
}
