import Foundation
import Permission

class NotificationSettings {

    private static let PREF_SURVEY_ENABLED = "pref_survey_enabled"
    private static let PREF_SURVEY_INTERVAL = "pref_survey_interval"
    private static let PREF_SURVEY_LAST_MILLIS = "pref_survey_last_millis"
    
    private static let PREF_BUS_NOTIFICATION_ENABLED = "pref_bus_notification_enabled"
    private static let PREF_TRIP_NOTIFICATION_ENABLED = "pref_trip_notification_enabled"
    private static let PREF_NEWS_NOTIFICATION_ENABLED = "pref_news_notification_enabled"
    
    
    // ====================================================================================================
    
    static func areSurveysEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_SURVEY_ENABLED)
    }
    
    static func setSurveysEnabled(_ enabled: Bool) {
        return UserDefaults.standard.set(enabled, forKey: PREF_SURVEY_ENABLED)
    }

    static func getSurveyInterval() -> Int {
        return UserDefaults.standard.integer(forKey: PREF_SURVEY_INTERVAL)
    }

    static func getLastSurveyMillis() -> Int64 {
        return Int64(UserDefaults.standard.double(forKey: PREF_SURVEY_LAST_MILLIS))
    }

    static func setLastSurveyMillis(millis: Int64) {
        UserDefaults.standard.set(Double(millis), forKey: PREF_SURVEY_LAST_MILLIS)
    }
    
    
    // ====================================================================================================
    
    static func isBusEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_BUS_NOTIFICATION_ENABLED)
    }
    
    static func setBusEnabled(_ enabled: Bool) {
        return UserDefaults.standard.set(enabled, forKey: PREF_BUS_NOTIFICATION_ENABLED)
    }
    
    
    // ====================================================================================================
    
    static func isTripEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_TRIP_NOTIFICATION_ENABLED)
    }
    
    static func setTripEnabled(_ enabled: Bool) {
        return UserDefaults.standard.set(enabled, forKey: PREF_TRIP_NOTIFICATION_ENABLED)
    }
    
    
    // ====================================================================================================
    
    static func isNewsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_NEWS_NOTIFICATION_ENABLED)
    }
    
    static func setNewsEnabled(_ enabled: Bool) {
        return UserDefaults.standard.set(enabled, forKey: PREF_NEWS_NOTIFICATION_ENABLED)
    }

    
    // ====================================================================================================
    
    static func askForPermissionIfNeeded() {
        let enabled = isBusEnabled() ||
            isTripEnabled() ||
            isNewsEnabled()
        
        if enabled {
            let notification: Permission = .notifications
            
            if notification.status != .authorized {
                notification.request { status in
                    if status == .authorized {
                        Log.info("Notification permission authorized")
                    } else {
                        Log.warning("Notification permission denied: \(status.description)")
                        disableAllNotifications()
                    }
                }
            }
        }
    }
    
    static func disableAllNotifications() {
        Log.warning("Disabling all notifications")
        
        setBusEnabled(false)
        setTripEnabled(false)
        setNewsEnabled(false)
        setSurveysEnabled(false)
    }
}
