import Foundation
import MapKit

class Settings {

    private static let PREF_INTRO_FINISHED = "pref_intro_finished"

    private static let PREF_START_SCREEN = "pref_start_screen"
    
    private static let PREF_CRASHLYTICS_DEVICE_ID = "pref_crashlytics_device_id"
    
    private static let PREF_BEACONS_ENABLED = "pref_beacons_enabled"
    
    private static let PREF_FORCE_DATA_DOWNLOAD = "pref_force_data_download"


    static func registerDefaults() {
        let defaultPrefsFile = Bundle.main.path(forResource: "DefaultSettings", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as! [String : AnyObject]

        UserDefaults.standard.register(defaults: defaultPrefs)
        UserDefaults.standard.synchronize()
        
        deleteObsoleteKeys()
    }
    
    static func deleteObsoleteKeys() {
        let keys = [
            "PRIVACY_HTML_KEY",
            "SURVEY_CYCLE_KEY",
            "BUS_STATION_FAVORITES_KEY",
            "DATA_DOWNLOADED_DONE_KEY",
            "MAP_DOWNLOADED_DONE_KEY",
            "ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY"
        ]
        
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
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
            UserDefaults.standard.set(DeviceUtils.getIdentifier(), forKey: PREF_CRASHLYTICS_DEVICE_ID)
        }
        
        return DeviceUtils.getIdentifier()
    }


    static func areBeaconsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_BEACONS_ENABLED)
    }
    
    static func setBeaconsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: PREF_BEACONS_ENABLED)
    }


    static func shouldForceDataDownload() -> Bool {
        let value = UserDefaults.standard.bool(forKey: PREF_FORCE_DATA_DOWNLOAD)
        
        if value {
            Log.warning("Forcing data redownload")
        }
        
        UserDefaults.standard.set(false, forKey: PREF_FORCE_DATA_DOWNLOAD)
        
        return value
    }
}
