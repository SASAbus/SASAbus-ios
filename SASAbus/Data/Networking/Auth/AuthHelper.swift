import Foundation
import Alamofire

class AuthHelper {

    static let PREF_AUTH_TOKEN = "pref_auth_token"
    static let PREF_USER_ID = "pref_user_id"
    static let PREF_IS_GOOGLE_ACCOUNT = "pref_is_google_account"


    // =============================================== KEYS =====================================================

    static func getPublicKey() throws -> RSAKey {
        let path = Bundle.main.url(forResource: "public_key", withExtension: "cer")

        let certificateData = try Data(contentsOf: path!, options: .dataReadingMapped)
        return try RSAKey(certificateData: certificateData)
    }


    // =============================================== PREFERENCES =====================================================

    static func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: PREF_AUTH_TOKEN)
    }

    static func setAuthToken(token: String?) {
        UserDefaults.standard.set(token, forKey: PREF_AUTH_TOKEN)
    }

    static func isGoogleAccount() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_IS_GOOGLE_ACCOUNT)
    }

    static func setIsGoogleAccount(value: Bool) {
        UserDefaults.standard.set(value, forKey: PREF_IS_GOOGLE_ACCOUNT)
    }

    static func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: PREF_USER_ID)
    }

    private static func setUserId(userId: String?) {
        UserDefaults.standard.set(userId, forKey: PREF_USER_ID)
    }

// =========================================== TOKEN VERIFICATION ==================================================

    static func getTokenIfValid() -> String? {
        if isLoggedIn() {
            return getAuthToken()
        }

        return nil
    }

    static func isLoggedIn() -> Bool {
        let token = getAuthToken()

        if let token = token {
            return !token.isEmpty && isTokenValid(token: token)
        }

        return false
    }

    static func isTokenValid(token: String) -> Bool {
        do {
            let jwt = try JSONWebToken(string: token)
            let validator = try RSAPKCS1Verifier(key: getPublicKey(), hashFunction: .sha256)

            let validationResult = validator.validateToken(jwt)
            if !validationResult.isValid {
                Log.error("Validation failed: \(validationResult)")
                return false
            }

            guard let userId = jwt.payload.subject, !userId.isEmpty else {
                Log.error("Token user id is empty")
                clearCredentials()
                return false
            }

            guard let savedUserId = getUserId(), !savedUserId.isEmpty else {
                Log.error("Saved user id is empty")
                clearCredentials()
                return false
            }

            if savedUserId != userId {
                Log.error("Saved user id and token user id don't match: savedUserId='\(savedUserId)', userId='\(userId)'")
                clearCredentials()
                return false
            }

            return true
        } catch let error {
            Log.error("Could not verify JWT: \(error)")
            clearCredentials()
            return false
        }
    }

    static func setInitialToken(token: String) -> Bool {
        do {
            let jwt = try JSONWebToken(string: token)
            let validator = try RSAPKCS1Verifier(key: getPublicKey(), hashFunction: .sha256)

            let validationResult = validator.validateToken(jwt)
            if !validationResult.isValid {
                Log.error("Validation failed: \(validationResult)")
                clearCredentials()
                return false
            }

            guard let userId = jwt.payload.subject, !userId.isEmpty else {
                Log.error("User id is empty")
                clearCredentials()
                return false
            }

            Log.debug("Token is valid, got user id: \(userId)")

            setUserId(userId: userId)
            setAuthToken(token: token)

            return true
        } catch let error {
            Log.error("Could not verify JWT: \(error)")
            clearCredentials()
            return false
        }
    }

    static func logout() {
        setAuthToken(token: nil)
        setUserId(userId: nil)

        setIsGoogleAccount(value: false)

        GIDSignIn.sharedInstance().signOut()
    }

    static func checkIfUnauthorized(_ error: Error) {
        guard let error = error as? AFError else {
            Log.error("Not a AFError error")
            return
        }
        
        if error.responseCode == 401 {
            Log.error("Unauthorized response, clearing credentials")
            logout()
        }
    }

    static func clearCredentials() {
        setUserId(userId: nil)
        setAuthToken(token: nil)
        setIsGoogleAccount(value: false)

        Log.error("Cleared credentials")
    }
}
