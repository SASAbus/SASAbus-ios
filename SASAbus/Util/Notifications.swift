import Foundation
import UserNotifications

class Notifications {

    static func badge(badge: InAppBadge) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()

        content.title = badge.title
        content.body = badge.summary
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "badge_notification"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "badge"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                Log.error("Problem adding notification: \(error.localizedDescription)")
            } else {
                Log.error("Successfully added notification")
            }
        }
    }

    static func trip(trip: CloudTrip) {
        let content = UNMutableNotificationContent()

        let originName = BusStopRealmHelper.getName(id: trip.origin)
        let destinationName = BusStopRealmHelper.getName(id: trip.destination)

        content.title =  L10n.Notification.Trip.title
        content.body =  L10n.Notification.Trip.body(originName, destinationName)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "trip_notification"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "trip"

        add(identifier: identifier, content: content, trigger: trigger)
    }

    static func survey(hash: String) {
        let content = UNMutableNotificationContent()

        content.title = L10n.Notification.Survey.title
        content.body =  L10n.Notification.Survey.body
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "survey_notification"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "survey"

        add(identifier: identifier, content: content, trigger: trigger)
    }
    
    static func news(title: String) {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = L10n.Notification.News.clickForMore
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "news_notification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "news"
        
        add(identifier: identifier, content: content, trigger: trigger)
    }


    // ==================================================== UTILS ======================================================

    static func clearAll() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private static func add(identifier: String, content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                Log.error("Problem adding \(identifier) notification: \(error.localizedDescription)")
            } else {
                Log.error("Successfully added \(identifier) notification")
            }
        }
    }
}
