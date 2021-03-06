//
// Created by Katherine Ebel on 11/10/20.
//

import LeafKit

extension BlogPostModel: LeafDataRepresentable {
  var leafData: LeafData {
    .dictionary([
      "id": .string(id?.uuidString),
      "title": .string(title),
      "slug": .string(slug),
      "image": .string(image),
      "excerpt": .string(excerpt),
      "date": .double(date.timeIntervalSinceReferenceDate),
      "content": .string(content),
      "category": $category.value != nil ? category.leafData : .dictionary(nil),
    ])
  }
}
