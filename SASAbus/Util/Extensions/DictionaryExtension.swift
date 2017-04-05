//
// Created by Alex Lardschneider on 05/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

extension Dictionary where Key == Int, Value == BusBeacon {

    static func +=<Int, BusBeacon>(left: inout [Int : BusBeacon], right: [Int : BusBeacon]) {
        for (k, v) in right {
            left[k] = v
        }
    }
}
