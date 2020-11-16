//
// Created by Katherine Ebel on 11/13/20.
//

import Vapor
import Fluent
import LeafKit

struct BlogCategoryAdminController: ResourceController {
  typealias EditForm = BlogCategoryForm
  typealias Model = BlogCategoryModel
  
  var listView: String = "Blog/Admin/Categories/List"
  var editView: String = "Blog/Admin/Categories/Edit"
  var redirectURL: String  { "admin/blog/categories" }
}
