//
//  BlogPost.swift
//  
//
//  Created by Katherine Ebel on 11/9/20.
//

import Foundation

struct BlogPost: Encodable {
  let title: String
  let slug: String
  let image: String
  let excerpt: String
  let date: Date
  var category: String?
  let content: String

}
