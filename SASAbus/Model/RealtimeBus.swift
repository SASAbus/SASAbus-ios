//
// RealtimeBus.swift
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
import UIKit
import SwiftyJSON

final class RealtimeBus: JSONable {

    var latitude: Double
    var longitude: Double

    var lineId: Int
    var lineName: String

    var busStop: Int
    var origin: Int
    var destination: Int

    var path: [Int]

    var trip: Int
    var variant: Int
    var vehicle: Int

    var inserted_min_ago: Int
    var updated_min_ago: Int

    var colorHex: String
    var zone: String

    var delay: Int
    var departure: Int

    var locationNumber: Int?

    var busStopString: String
    var destinationString: String

    required init(parameter: JSON) {
        latitude = parameter["latitude"].doubleValue
        longitude = parameter["longitude"].doubleValue

        lineId = parameter["line_id"].intValue
        lineName = parameter["line_name"].stringValue

        busStop = parameter["bus_stop"].intValue
        origin = parameter["origin"].intValue
        destination = parameter["destination"].intValue

        path = parameter["path"].arrayValue.map {
            $0.intValue
        }

        trip = parameter["trip"].intValue
        variant = parameter["variant"].intValue
        vehicle = parameter["vehicle"].intValue

        inserted_min_ago = parameter["inserted_min_ago"].intValue
        updated_min_ago = parameter["updated_min_ago"].intValue

        colorHex = parameter["color_hex"].stringValue
        zone = parameter["zone"].stringValue

        delay = parameter["delay_min"].intValue
        departure = parameter["departure"].intValue

        busStopString = "NOT INITIALIZED"
        destinationString = "NOT INITIALIZED"
    }

    func getCoordinates() -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    static func collection(parameter: JSON) -> [RealtimeBus] {
        var items: [RealtimeBus] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(RealtimeBus(parameter: itemRepresentation))
        }

        return items
    }
}
