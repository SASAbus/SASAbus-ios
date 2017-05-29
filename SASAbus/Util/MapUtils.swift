//
// Created by Alex Lardschneider on 06/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import CoreLocation

class MapUtils {

    static func distance(first: CLLocation, second: CLLocation) -> Double {
        return first.distance(from: second)
    }
}
