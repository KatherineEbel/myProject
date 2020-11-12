//
// Created by Katherine Ebel on 11/12/20.
//

import Vapor

struct FormFieldStringOption: Content {
  let key: String
  let label: String

  static func fromModel<T: FormFieldStringOptionRepresentable>(_ model: T) -> FormFieldStringOption {
    model.formFieldStringOption
  }
}
