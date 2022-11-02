import Vapor
import Leaf

func routes(_ app: Application) throws {
    app.get { req async throws -> View in
        return try await req.view.render("index")
    }

    app.get("login") { req async throws -> View in
        return try await req.view.render("login")
    }

    app.get("callback") { req async throws -> View in
        guard let code = req.query[String.self, at: "code"] else {
            return try await req.view.render(
                "error",
                [
                    "errorKey": req.query[String.self, at: "error"],
                    "errorMessage": req.query[String.self, at: "error_description"]?.replacingOccurrences(of: "+", with: " ")
                ]
            )
        }
        let tokenResponse = try await req.client.post("http://localhost:8090/oauth/token") { tokenReq in
            let tokenReqData = TokenRequestData(
                code: code,
                grantType: "authorization_code",
                redirectUri: "http://localhost:8080/callback",
                clientId: "1",
                clientSecret: "password123"
            )
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            try tokenReq.content.encode(tokenReqData, using: encoder)
        }

        return try await req.view.render(
            "success",
            SuccessViewContext(
                expiryInMinutes: try tokenResponse.content.get(Int.self, at: "expires_in"),
                accessToken: try tokenResponse.content.get(String.self, at: "access_token"),
                refreshToken: try tokenResponse.content.get(String.self, at: "refresh_token"),
                scope: try tokenResponse.content.get(String.self, at: "scope")
            )
        )
    }
}

struct TokenRequestData: Content {
    let code: String
    let grantType: String
    let redirectUri: String
    let clientId: String
    let clientSecret: String
}