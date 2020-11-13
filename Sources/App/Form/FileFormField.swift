//
// Created by Katherine Ebel on 11/12/20.
//

import Foundation
import Vapor

struct FileFormField: Content, FormFieldRepresentable {
  var value: String = ""
  var error: String? = nil
  var data: Data? = nil
  var delete: Bool = false
}
