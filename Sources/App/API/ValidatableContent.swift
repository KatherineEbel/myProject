//
// Created by Katherine Ebel on 11/16/20.
//

import Vapor

protocol ValidatableContent: Content, Validatable {
}

extension ValidatableContent {
  public static func validations(_ validations: inout Validations) {

  }
}
