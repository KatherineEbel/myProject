//
// Created by Katherine Ebel on 11/12/20.
//

import Foundation
import Vapor

struct FormField<Type: Content>: Content, FormFieldRepresentable {
  typealias Value = Type
  var value: Type
  var error: String? = nil

  init(value: Type) {
    self.value = value
  }
}
