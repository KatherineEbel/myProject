//
// Created by Katherine Ebel on 11/16/20.
//

import Vapor

protocol GetContentRepresentable {
  associatedtype GetContent: Content

  var getContent: GetContent { get }
}
