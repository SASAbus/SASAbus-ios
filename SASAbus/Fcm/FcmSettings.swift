import Foundation

class FcmSettings {
    
    static let PREF_FCM_TOKEN = "pref_fcm_token"
    static let PREF_CURRENT_NEWS_TOPIC = "pref_current_news_topic"
    
    
    static func setFcmToken(token: String?) {
        UserDefaults.standard.set(token, forKey: PREF_FCM_TOKEN)
    }
    
    static func getFcmToken() -> String? {
        return UserDefaults.standard.string(forKey: PREF_FCM_TOKEN)
    }
    
    
    static func setCurrentNewsTopic(topic: String?) {
        UserDefaults.standard.set(topic, forKey: PREF_CURRENT_NEWS_TOPIC)
    }
    
    static func getCurrentNewsTopic() -> String? {
        return UserDefaults.standard.string(forKey: PREF_CURRENT_NEWS_TOPIC)
    }
}
