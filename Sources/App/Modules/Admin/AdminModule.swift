//
// Created by Katherine Ebel on 11/10/20.
//

import Vapor
import Fluent

struct AdminModule: Module {
  var router: RouteCollection? { AdminRouter() }
}
