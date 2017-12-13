import Foundation
import Crashlytics

class ErrorHelper {
    
    static func log(_ error: Error, message: String? = nil) {
        if let message = message {
            Log.error("ERROR: message='\(message)', error='\(error.localizedDescription)'")
        } else {
            Log.error("ERROR: error='\(error.localizedDescription)'")
        }

        #if RELEASE
            if let message = message {
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["message": message])
            } else {
                Crashlytics.sharedInstance().recordError(error)
            }
        #endif
    }
}
