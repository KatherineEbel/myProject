//
//  BlogFrontendController.swift
//  
//
//  Created by Katherine Ebel on 11/9/20.
//

import Vapor
import Fluent
import LoremSwiftum

struct BlogFrontendController {
  func blogView(req: Request) throws -> EventLoopFuture<View> {
    BlogPostModel.query(on: req.db)
      .sort(\.$date, .descending)
      .with(\.$category)
      .all()
      .flatMap { posts in
        req.view.render("Blog/Frontend/Blog", BlogViewContext(title: "myPage - Blog", posts: posts))
      }
  }

  func postView(_ req: Request) -> EventLoopFuture<Response> {
    let slug = req.url.path.trimmingCharacters(in: .init(charactersIn: "/"))
    return BlogPostModel.query(on: req.db)
      .filter(\.$slug == slug)
      .with(\.$category)
      .first()
      .flatMap { post -> EventLoopFuture<Response> in
        guard let post = post else {
          return req.eventLoop.future(req.redirect(to: "/"))
      }
      return req.view
        .render("Blog/Frontend/Post", PostViewContext(title: post.title, post: post))
        .encodeResponse(for: req)
    }
  }
}

struct BlogViewContext: Encodable {
  let title: String
  let posts: [BlogPostModel]
}

struct PostViewContext: Encodable {
  let title: String
  let post: BlogPostModel
}