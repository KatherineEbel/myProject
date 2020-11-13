//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

struct AdminModule: Module {
  private(set) static var name: String = "admin"
  var router: RouteCollection? { AdminRouter() }
}
