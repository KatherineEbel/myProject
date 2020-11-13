//
// Created by Katherine Ebel on 11/12/20.
//

import Foundation

protocol FormFieldRepresentable {
  associatedtype Value: Codable
  var value: Value { get set }
  var error: String? { get set }
}
