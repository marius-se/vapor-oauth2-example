import Vapor
import VaporOAuth
import Leaf

struct LiveAuthorizeHandler: AuthorizeHandler {
    func handleAuthorizationRequest(
        _ request: Request,
        authorizationRequestObject: AuthorizationRequestObject
    ) async throws -> Response {
        let viewContext = AuthorizeViewContext(
            scopes: authorizationRequestObject.scope,
            clientID: authorizationRequestObject.clientID,
            csrfToken: authorizationRequestObject.csrfToken
        )
        return try await request.view.render("authorize", viewContext).encodeResponse(for: request)
    }

    func handleAuthorizationError(_ errorType: AuthorizationError) async throws -> Response {
        return Response(status: .imATeapot, body: .init(string: errorType.localizedDescription))
    }


}

struct AuthorizeViewContext: Encodable {
    let scopes: [String]
    let clientID: String
    let csrfToken: String
}
