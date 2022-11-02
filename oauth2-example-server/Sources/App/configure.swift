import Fluent
import FluentSQLiteDriver
import Vapor
import VaporOAuth
import Leaf

public func configure(_ app: Application) throws {
    app.http.server.configuration.port = 8090

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateAccessToken())
    app.migrations.add(CreateRefreshToken())

    try app.autoMigrate().wait()

    app.middleware.use(app.sessions.middleware)
    app.middleware.use(OAuthUserSessionAuthenticator())

    app.views.use(.leaf)

    let someOAuthClient = OAuthClient(
        clientID: "1",
        redirectURIs: ["http://localhost:8080/callback"],
        clientSecret: "password123",
        validScopes: ["admin"],
        allowedGrantType: .authorization
    )

    let tokenManager = LiveTokenManager(app: app)
    app.lifecycle.use(
        OAuth2(
            codeManager: LiveCodeManger(),
            tokenManager: tokenManager,
            clientRetriever: StaticClientRetriever(clients: [someOAuthClient]),
            authorizeHandler: LiveAuthorizeHandler(),
            validScopes: ["admin"],
            oAuthHelper: .local(
                tokenAuthenticator: TokenAuthenticator(),
                userManager: nil,
                tokenManager: tokenManager
            )
        )
    )

    try routes(app)
}

struct OAuthUserSessionAuthenticator: AsyncSessionAuthenticator {
    public typealias User = OAuthUser

    public func authenticate(sessionID: String, for request: Vapor.Request) async throws {
        let user = OAuthUser(
            userID: "1",
            username: "marius",
            emailAddress: "marius.seufzer@code.berlin",
            password: "password"
        )
        request.auth.login(user)
    }
}

extension OAuthUser: SessionAuthenticatable {
    public var sessionID: String { self.id ?? "" }
}