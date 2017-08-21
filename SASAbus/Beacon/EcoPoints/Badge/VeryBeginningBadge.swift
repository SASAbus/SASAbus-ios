//
// Created by Alex Lardschneider on 06/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class VeryBeginningBadge: InAppBadge {

    init() {
        super.init(id: 110, title: "The very beginning", summary: "Go to a bus stop and scan the attached beacon!",
                icon: "badge_red_stop")
    }

    override func evaluate(beacon: AbsBeacon) -> Bool {
        if !super.evaluate(beacon: beacon) {
            return false
        }

        // Since we only want to know if the user scanned a bus stop beacon, we only have to
        // check if the passed beacon is a bus stop beacon, as the condition will be met then.
        return beacon is BusStopBeacon
    }
}
