//
// Created by Katherine Ebel on 11/13/20.
//

import Vapor
import LeafKit
import Fluent

protocol Form: Content {
  associatedtype Input: Validatable
  associatedtype Model: Fluent.Model
  
  var id: UUID? { get set }
  
  init()
  init(req: Request) throws
  
  func write(to: Model)

  func read(from: Model)
}
