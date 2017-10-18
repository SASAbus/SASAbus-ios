//
// Created by Alex Lardschneider on 06/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class FirstStepBadge: InAppBadge {

    init() {
        super.init(id: 120, title: "On the bus", summary: "Scan a beacon located in one of the buses!", icon: "badge_blue_bus")
    }

    override func evaluate(beacon: AbsBeacon) -> Bool {
        if !super.evaluate(beacon: beacon) {
            return false
        }

        // Since we only want to know if the user scanned a bus beacon, we only have to
        // check if the passed beacon is a bus beacon, as the condition will be met then.
        return beacon is BusBeacon
    }
}
