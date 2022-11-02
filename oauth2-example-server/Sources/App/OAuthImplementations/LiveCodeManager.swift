import VaporOAuth
import Vapor

class LiveCodeManger: CodeManager {
    private(set) var usedCodes: [String] = []
    private(set) var codes: [String: OAuthCode] = [:]

    func generateCode(userID: String, clientID: String, redirectURI: String, scopes: [String]?) throws -> String {
        let generatedCode = UUID().uuidString
        let code = OAuthCode(
            codeID: generatedCode,
            clientID: clientID,
            redirectURI: redirectURI,
            userID: userID,
            expiryDate: Date().addingTimeInterval(60),
            scopes: scopes
        )
        codes[generatedCode] = code
        return generatedCode
    }

    func getCode(_ code: String) -> OAuthCode? {
        return codes[code]
    }

    func codeUsed(_ code: OAuthCode) {
        usedCodes.append(code.codeID)
        codes.removeValue(forKey: code.codeID)
    }
}