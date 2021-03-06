//
// Created by Katherine Ebel on 11/10/20.
//

import LeafKit

extension BlogCategoryModel: LeafDataRepresentable {
  var leafData: LeafData {
    .dictionary([
      "id": .string(id?.uuidString),
      "title": .string(title),
    ])
  }
}

