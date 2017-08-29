import Foundation
import MapKit

class Settings {

    private static let PREF_INTRO_FINISHED = "pref_intro_finished"

    private static let PREF_START_SCREEN = "pref_start_screen"
    
    private static let PREF_CRASHLYTICS_DEVICE_ID = "pref_crashlytics_device_id"


    static func registerDefaults() {
        let defaultPrefsFile = Bundle.main.path(forResource: "DefaultSettings", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as! [String : AnyObject]

        UserDefaults.standard.register(defaults: defaultPrefs)
        UserDefaults.standard.synchronize()
    }


    static func isIntroFinished() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_INTRO_FINISHED)
    }

    static func setIntroFinished() {
        UserDefaults.standard.set(true, forKey: PREF_INTRO_FINISHED)
    }


    static func getStartScreen() -> Int {
        return UserDefaults.standard.integer(forKey: PREF_START_SCREEN)
    }
    
    
    static func getCrashlyticsDeviceId() -> String {
        let uuid = UserDefaults.standard.string(forKey: PREF_CRASHLYTICS_DEVICE_ID)
        
        if uuid == nil {
            UserDefaults.standard.set(UIDevice.current.identifierForVendor?.uuidString, forKey: PREF_CRASHLYTICS_DEVICE_ID)
        }
        
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
