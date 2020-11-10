//
// Created by Katherine Ebel on 11/9/20.
//

import Vapor

struct BlogRouter: RouteCollection {
  let controller = BlogFrontendController()

  func boot(routes: RoutesBuilder) throws {
    routes.get("blog", use: controller.blogView)
    routes.get(.anything, use: controller.postView)
  }
}
