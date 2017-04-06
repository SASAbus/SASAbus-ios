//
// Created by Alex Lardschneider on 06/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class BadgeHelper {

    private static var BADGES: [InAppBadge] = {
        var list = [InAppBadge]()
        list.append(FirstStepBadge())
        list.append(VeryBeginningBadge())
        return list
    }()

    static func evaluate(beacon: AbsBeacon) {
        for badge in BADGES {
            if !badge.completed() && badge.evaluate(beacon: beacon) {
                Log.error("Completed badge \(badge.id)")

                badge.complete()

                Notifications.badge(badge: badge)
            }
        }
    }
}
