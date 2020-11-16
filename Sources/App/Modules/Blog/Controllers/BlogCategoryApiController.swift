//
// Created by Katherine Ebel on 11/15/20.
//

import Foundation

struct BlogCategoryApiController: ListContentController,
  GetContentController,
  CreateContentController,
  UpdateContentController,
  PatchContentController,
  DeleteContentController {
  typealias Model = BlogCategoryModel
}
