import Foundation
import MapKit

class Settings {

    static let PREF_INTRO_FINISHED = "pref_intro_finished"
    static let PREF_MAP_TYPE = "pref_map_type"
    static let PREF_AUTO_REFRESH_ENABLED = "pref_map_auto_refresh_enabled"
    static let PREF_AUTO_REFRESH_INTERVAL = "pref_map_auto_refresh_interval"
    static let PREF_TILE_OVERLAY_ENABLED = "pref_tile_overlay_enabled"
    static let PREF_TILE_OVERLAY_ENABLED_ALL = "pref_tile_overlay_enabled_all"
    static let PREF_BUS_BEACONS_ENABLED = "pref_bus_beacons_enabled"

    static let PREF_SURVEY_ENABLED = "pref_survey_enabled"
    static let PREF_SURVEY_INTERVAL = "pref_survey_interval"
    static let PREF_SURVEY_LAST_MILLIS = "pref_survey_last_millis"

    static let PREF_TRIP_NOTIFICATION_ENABLED = "pref_trips_enabled"

    static func registerDefaults() {
        let defaultPrefsFile = Bundle.main.path(forResource: "DefaultSettings", ofType: "plist")
        let defaultPrefs = NSDictionary(contentsOfFile: defaultPrefsFile!) as! [String : AnyObject]

        UserDefaults.standard.register(defaults: defaultPrefs)
        UserDefaults.standard.synchronize()
    }

    static func getMapType() -> MKMapType? {
        let userDefaults = UserDefaults.standard
        let mapType = userDefaults.string(forKey: PREF_MAP_TYPE) ?? "standard"

        switch mapType {
            case "standard":
                return MKMapType.standard
            case "hybrid":
                return MKMapType.hybrid
            case "satellite":
                return MKMapType.satellite
            default:
                Log.error("Invalid map type: \(mapType), returning default")
                return MKMapType.standard
        }
    }

    static func mapOverlaysEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_TILE_OVERLAY_ENABLED)
    }

    static func allMapOverlaysEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_TILE_OVERLAY_ENABLED_ALL)
    }

    static func isIntroFinished() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_INTRO_FINISHED)
    }

    static func setIntroFinished() {
        UserDefaults.standard.set(true, forKey: PREF_INTRO_FINISHED)
    }

    static func isBusNotificationEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_BUS_BEACONS_ENABLED)
    }

    static func isSurveyEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_SURVEY_ENABLED)
    }

    static func getSurveyInterval() -> Int {
        return UserDefaults.standard.integer(forKey: PREF_SURVEY_INTERVAL)
    }

    static func getLastSurveyMillis() -> Int64 {
        return UserDefaults.standard.object(forKey: PREF_SURVEY_LAST_MILLIS) as! Int64
    }

    static func setLastSurveyMillis(millis: Int64) {
        return UserDefaults.standard.set(millis, forKey: PREF_SURVEY_LAST_MILLIS)
    }

    static func isTripNotificationEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_TRIP_NOTIFICATION_ENABLED)
    }
}
