import Foundation
import Firebase

class FcmUtils {

    static func checkForNewsSubscription() {
        guard FcmSettings.getFcmToken() != nil else {
            return
        }

        if NotificationSettings.isNewsEnabled() {
            subscribeToNews()
        } else {
            unSubscribeFromNews()
        }
    }


    static func subscribeToNews() {
        guard FcmSettings.getCurrentNewsTopic() == nil else {
            return
        }

        let topic = "news_" + Utils.localeDeIt()
        FcmSettings.setCurrentNewsTopic(topic: topic)

        Log.warning("Subscribing to news topic '\(topic)'")

        DispatchQueue.main.async {
            Messaging.messaging().subscribe(toTopic: topic)
        }
    }

    static func unSubscribeFromNews() {
        guard let topic = FcmSettings.getCurrentNewsTopic() else {
            Log.warning("No news topic to unsubscribe from")
            return
        }

        Log.warning("Unsubscribing from news topic '\(topic)'")
        FcmSettings.setCurrentNewsTopic(topic: nil)

        DispatchQueue.main.async {
            Messaging.messaging().unsubscribe(fromTopic: topic)
        }
    }

    
    static func handleFcmMessage(userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo["gcm.message_id"] {
            Log.warning("Message ID: \(messageID)")
        }
        
        Log.warning(userInfo)
        
        guard let receiver = userInfo["receiver"] as? String else {
            Log.error("Notification has no receiver, ignoring")
            return
        }
        
        Log.info("Receiver is: '\(receiver)'")
        
        switch receiver {
        case "news":
            handleNewsNotification(userInfo: userInfo)
        default:
            Log.error("Unknown receiver '\(receiver)'")
        }
    }
    
    static func handleNewsNotification(userInfo: [AnyHashable: Any]) {
        guard let title = userInfo["title"] as? String else {
            Log.error("News title is missing or not a string")
            return
        }
        
        Notifications.news(title: title)
    }
}
