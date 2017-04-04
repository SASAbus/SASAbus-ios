//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class HashUtils {

    static func getHashForTrip(beacon: BusBeacon) -> String {
        return UUID().uuidString
    }
}
