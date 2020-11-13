//
// Created by Katherine Ebel on 11/10/20.
//

import Foundation
import Vapor

struct FrontendModule: Module {
  private(set) static var name: String = "frontend"
  var router: RouteCollection? { FrontendRouter() }
}
