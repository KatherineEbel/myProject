//
// Created by Katherine Ebel on 11/9/20.
//

import Vapor

struct BlogRouter: RouteCollection {
  let frontendController = BlogFrontendController()
  let adminController = BlogPostAdminController()

  func boot(routes: RoutesBuilder) throws {
    routes.get("blog", use: frontendController.blogView)
    routes.get(.anything, use: frontendController.postView)

    let protected = routes.grouped([
      UserModel.sessionAuthenticator(),
      UserModel.redirectMiddleware(path: "/")
    ])

    let blog = protected.grouped("admin", "blog")
    let posts = blog.grouped("posts")

    posts.get(use: adminController.listView)
    posts.get("new", use: adminController.createView)
    posts.post("new", use: adminController.create)

    let edit = posts.grouped(":id")
    edit.get(use: adminController.createView)
    edit.post(use: adminController.create)
    edit.post("delete", use: adminController.delete)
  }
}
