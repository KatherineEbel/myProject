//
// Created by Katherine Ebel on 11/15/20.
//

import Vapor

protocol ListContentRepresentable {
  associatedtype ListItem: Content

  var listContent: ListItem { get }
}
