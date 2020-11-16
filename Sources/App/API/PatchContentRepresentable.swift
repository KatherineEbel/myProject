//
// Created by Katherine Ebel on 11/16/20.
//

import Vapor

protocol PatchContentRepresentable: GetContentRepresentable {
  associatedtype PatchContent: ValidatableContent

  func patch(_: PatchContent) throws
}

extension PatchContentRepresentable {
  func patch(_ content: PatchContent) throws {}
}
