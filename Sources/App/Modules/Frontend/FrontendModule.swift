//
// Created by Katherine Ebel on 11/10/20.
//

import Foundation
import Vapor

struct FrontendModule: Module {
  var router: RouteCollection? { FrontendRouter() }
}
