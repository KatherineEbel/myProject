//
// Created by Katherine Ebel on 11/13/20.
//

import Vapor
import Fluent

struct UtilityModule: Module {
  static var name: String = "utility"
  var commandGroup: CommandGroup? { UtilityCommandGroup() }
}
