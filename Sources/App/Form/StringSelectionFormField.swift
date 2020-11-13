//
// Created by Katherine Ebel on 11/12/20.
//

import Foundation
import Vapor

struct StringSelectionFormField: Content, FormFieldRepresentable {
  typealias Value = String
  var value: Value = ""
  var error: String? = nil
  var options: [FormFieldStringOption] = []
}
