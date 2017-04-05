//
// Created by Alex Lardschneider on 04/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import UserNotifications
import ObjectMapper

class TripNotification {

    static func show(trip: CurrentTrip) {
        Log.warning("Showing notification for vehicle \(trip.id)")

        if trip.isNotificationVisible {
            Log.trace("Notification for vehicle \(trip.id) already visible")
            // return
        }

        trip.isNotificationVisible = true

        let center = UNUserNotificationCenter.current()

        let json = Mapper().toJSONString(trip, prettyPrint: false)

        let content = UNMutableNotificationContent()

        content.title = trip.title
        content.body = "Press to view details"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "trip_notification"
        content.userInfo = ["trip": json]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "trip"

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                Log.error("Problem adding notification: \(error.localizedDescription)")
            } else {
                Log.error("Successfully added notification")
            }
        }
    }

    static func hide(trip: CurrentTrip?) {
        Log.warning("Hiding notification for vehicle \(trip?.id)")

        if let trip = trip {
            trip.isNotificationVisible = false
        }

        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: ["trip"])
        center.removePendingNotificationRequests(withIdentifiers: ["trip"])
    }
}
