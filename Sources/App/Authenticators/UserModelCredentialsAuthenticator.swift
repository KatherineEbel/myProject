import Vapor
import Fluent

struct UserModelCredentialsAuthenticator: CredentialsAuthenticator {
  struct Input: Content {
    let email: String
    let password: String
  }

  typealias Credentials = Input

  func authenticate(credentials: Credentials, for request: Request) -> EventLoopFuture<()> {
    UserModel.query(on: request.db)
      .filter(\.$email == credentials.email)
      .first()
      .map {
        do {
          if
            let user = $0,
            try request.password.verify(credentials.password, created: user.password) {
            request.auth.login(user)
          }
        } catch {
          print("User not found!!")
          // do nothing
        }
      }
  }
}