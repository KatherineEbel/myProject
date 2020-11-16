//
// Created by Katherine Ebel on 11/16/20.
//

import Foundation

protocol APIRepresentable: ListContentRepresentable,
  CreateContentRepresentable,
  UpdateContentRepresentable,
  PatchContentRepresentable,
  DeleteContentRepresentable {}
