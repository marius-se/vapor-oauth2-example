import Vapor
import VaporOAuth

func routes(_ app: Application) throws {
    app.routes.get("login", use: { req in
        req.auth.login(OAuthUser(
            userID: "1",
            username: "marius",
            emailAddress: "marius.seufzer@code.berlin",
            password: "password"
        ))
        let user = try req.auth.require(OAuthUser.self)
        print(user)
        return req.redirect(to: "http://localhost:8080/")
    })
}