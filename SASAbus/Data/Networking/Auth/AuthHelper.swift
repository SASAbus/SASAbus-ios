import Foundation

class AuthHelper {

    static let PREF_AUTH_TOKEN = "pref_auth_token"
    static let PREF_USER_ID = "pref_user_id"
    static let PREF_IS_GOOGLE_ACCOUNT = "pref_is_google_account"

    // =============================================== PREFERENCES =====================================================

    static func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: PREF_AUTH_TOKEN)
    }

    static func setAuthToken(token: String) {
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
        return true
    }

    static func setInitialToken(token: String) -> Bool {
        setAuthToken(token: token)
        return true
    }

}
