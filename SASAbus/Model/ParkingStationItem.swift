//
// ParkingStationItem.swift
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

import CoreLocation
import SwiftyJSON

final class ParkingStationItem: JSONable, JSONCollection {

    let phone: String
    let status: Int
    let address: String
    let slots: Int
    let description: String
    let name: String
    let location: CLLocation

    required init(parameter: JSON) {
        self.phone = parameter["phone"].stringValue
        self.status = parameter["status"].intValue

        self.address = parameter["address"].stringValue
        self.slots = parameter["slots"].intValue
        self.description = parameter["description"].stringValue
        self.name = parameter["name"].stringValue

        let longitude: CLLocationDegrees = parameter["longitude"].doubleValue
        let latitude: CLLocationDegrees = parameter["latitude"].doubleValue

        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }

    static func collection(parameter: JSON) -> [ParkingStationItem] {
        var items: [ParkingStationItem] = []

        for parking in parameter.arrayValue {
            items.append(ParkingStationItem(parameter: parking))
        }

        return items
    }
}
