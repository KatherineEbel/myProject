//
// Created by Katherine Ebel on 11/15/20.
//

import Vapor
import Fluent

struct BlogCategoryApiController: ListContentController,
  GetContentController,
  CreateContentController,
  UpdateContentController,
  PatchContentController,
  DeleteContentController {
  typealias Model = BlogCategoryModel

  func get(_ req: Request) throws -> EventLoopFuture<Model.GetContent> {
    print("BlogCategoryApiController") // TODO: Figure out why this method isn't being called
    return try self.find(req).flatMap { category in
      BlogPostModel.query(on: req.db)
        .filter(\.$category.$id == category.id!)
        .all()
        .map { posts in
          var details = category.getContent
          details.posts = posts.map(\.listContent)
          return details
        }
    }
  }

  func setupGetRoute(routes: RoutesBuilder) {
    routes.get(idPathComponent, use: get)
  }
}
