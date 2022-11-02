import Vapor
import VaporOAuth
import Fluent
import FluentKit

class LiveTokenManager: TokenManager {

    private let app: Application

    init(app: Application) {
        self.app = app
    }

    func generateAccessRefreshTokens(clientID: String, userID: String?, scopes: [String]?, accessTokenExpiryTime: Int) async throws -> (VaporOAuth.AccessToken, VaporOAuth.RefreshToken) {
        let accessToken = LiveAccessToken(
            tokenString: UUID().uuidString,
            clientID: clientID,
            userID: userID,
            scopes: scopes,
            expiryTime: Date(timeIntervalSinceNow: TimeInterval(accessTokenExpiryTime))
        )
        try await accessToken.save(on: app.db)

        let refreshToken = LiveRefreshToken(
            tokenString: UUID().uuidString,
            clientID: clientID,
            userID: userID,
            scopes: scopes
        )
        try await refreshToken.save(on: app.db)

        return (accessToken, refreshToken)
    }

    func generateAccessToken(clientID: String, userID: String?, scopes: [String]?, expiryTime: Int) async throws -> VaporOAuth.AccessToken {
        let accessToken = LiveAccessToken(
            tokenString: UUID().uuidString,
            clientID: clientID,
            userID: userID,
            scopes: scopes,
            expiryTime: Date(timeIntervalSinceNow: TimeInterval(expiryTime))
        )
        try await accessToken.save(on: app.db)
        return accessToken
    }

    func getRefreshToken(_ refreshToken: String) async throws -> VaporOAuth.RefreshToken? {
        return try await LiveRefreshToken.query(on: app.db)
            .filter(\.$tokenString == refreshToken)
            .first()
    }

    func getAccessToken(_ accessToken: String) async -> VaporOAuth.AccessToken? {
        return nil
    }

    func updateRefreshToken(_ refreshToken: VaporOAuth.RefreshToken, scopes: [String]) async {

    }

}