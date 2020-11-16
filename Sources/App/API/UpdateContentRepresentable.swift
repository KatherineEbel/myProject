//
// Created by Katherine Ebel on 11/16/20.
//

import Vapor

protocol UpdateContentRepresentable: GetContentRepresentable {
  associatedtype UpdateContent: ValidatableContent

  func update(_: UpdateContent) throws
}

extension UpdateContentRepresentable {
  func update(_ content: UpdateContent) throws {}
}
