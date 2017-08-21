import Foundation

class NotificationSettings {

    private static let PREF_SURVEY_ENABLED = "pref_survey_enabled"
    private static let PREF_SURVEY_INTERVAL = "pref_survey_interval"
    private static let PREF_SURVEY_LAST_MILLIS = "pref_survey_last_millis"

    static func isSurveyEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_SURVEY_ENABLED)
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
}
