//
// Created by Katherine Ebel on 11/13/20.
//

import Vapor
import Fluent

class UtilityFileTransferCommand: Command {
  static let name = "file-transfer"
  struct Signature: CommandSignature {}
  let help = "Transfers public files into the assets folder for the blog posts"

  func run(using context: CommandContext, signature: Signature) throws {
    let app = context.application
    let frames = ["﹕", "﹕", "⠇", "⠇", "⠼", "⠚", "⠦", "⠧", "⠇", "⠇"].map { $0 + " File transfer in progress..." }
    let loadingBar = context.console.customActivity(frames: frames)
    loadingBar.start()

    let publicPath = URL(fileURLWithPath: app.directory.publicDirectory)
    let assetsPath = URL(fileURLWithPath: app.directory.publicDirectory + "/assets/")
    do {
      let models = try BlogPostModel.query(on: app.db).all().wait()
      let originalModels = models.filter {
        $0.imageKey == nil && $0.image.hasPrefix("/images/posts/")
      }
      try originalModels.forEach { model in
        let key = "/blog/posts/" + UUID().uuidString + ".jpg"
        try FileManager.default
          .moveItem(at: publicPath.appendingPathComponent(model.image),
          to: assetsPath.appendingPathComponent(key))
        model.imageKey = key
        model.image = "http://localhost:8080/assets" + key
        try model.update(on: app.db).wait()
      }
      loadingBar.succeed()
    } catch {
      context.console.error(error.localizedDescription)
      loadingBar.fail()
    }
  }
}
