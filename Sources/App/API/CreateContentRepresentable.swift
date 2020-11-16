//
// Created by Katherine Ebel on 11/16/20.
//

import Vapor

protocol CreateContentRepresentable: GetContentRepresentable {
  associatedtype CreateContent: ValidatableContent

  func create(_: CreateContent) throws
}

extension CreateContentRepresentable {
  func create(_: CreateContent) throws {}
}
