//
// BusStationDistance.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreLocation

class BusStopDistance {

    let distance: CLLocationDistance!
    let busStop: BBusStop!

    init(busStop: BBusStop, distance: CLLocationDistance) {
        self.busStop = busStop
        self.distance = distance
    }
}

extension BusStopDistance: Hashable {
    
    var hashValue: Int {
        return busStop.family
    }
    
    public static func ==(lhs: BusStopDistance, rhs: BusStopDistance) -> Bool {
        return lhs.busStop.family == rhs.busStop.family
    }
}
