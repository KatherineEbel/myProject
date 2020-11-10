//
//  BlogFrontendController.swift
//  
//
//  Created by Katherine Ebel on 11/9/20.
//

import Vapor
import LoremSwiftum

struct BlogFrontendController {
  var posts: [BlogPost] = {
    stride(from: 0, to: 10, by: 1).map { index in
      let title = Lorem.title
      return BlogPost(title: title, slug: title.lowercased().replacingOccurrences(of: " ", with: "-"), image: "/images/posts/\(String(format: "%02d", index + 1)).jpg", excerpt: Lorem.sentence, date: Date().addingTimeInterval(-Double.random(in: 0...(86400 * 60))), category: Bool.random() ? Lorem.word.capitalized : "Uncategorized", content: Lorem.paragraph)
    }.sorted() { $0.date > $1.date }
  }()

  func blogView(req: Request) throws -> EventLoopFuture<View> {
    req.view.render("blog", BlogViewContext(title: "myPage - Blog", posts: posts))
  }

  func postView(_ req: Request) -> EventLoopFuture<Response> {
    let slug = req.url.path.trimmingCharacters(in: .init(charactersIn: "/"))
    guard let post = posts.first(where: { $0.slug == slug }) else {
      return req.eventLoop.future(req.redirect(to: "/"))
    }
    return req.view
      .render("post", PostViewContext(title: post.title, post: post))
      .encodeResponse(for: req)
  }
}

struct BlogViewContext: Encodable {
  let title: String
  let posts: [BlogPost]
}

struct PostViewContext: Encodable {
  let title: String
  let post: BlogPost
}