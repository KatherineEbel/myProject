//
// Created by Katherine Ebel on 11/9/20.
//

import Vapor

struct BlogRouter: RouteCollection {
  let frontendController = BlogFrontendController()
  let adminController = BlogPostAdminController()
  let categoryAdminController = BlogCategoryAdminController()

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

    let postsEdit = posts.grouped(":id")
    postsEdit.get(use: adminController.createView)
    postsEdit.post(use: adminController.create)
    postsEdit.post("delete", use: adminController.delete)
    
    let categories = blog.grouped("categories")
    categories.get(use: categoryAdminController.listView)
    
    let create = categories.grouped("new")
    create.get(use: categoryAdminController.createView)
    create.post(use: categoryAdminController.create)
    
    let categoriesEdit = categories.grouped(":id")
    categoriesEdit.get(use: categoryAdminController.updateView)
    categoriesEdit.post(use: categoryAdminController.update)
    categoriesEdit.post("delete", use: categoryAdminController.delete)
  }
}
