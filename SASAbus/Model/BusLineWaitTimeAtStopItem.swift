//
// BusLineWaitTimeAtStopItem.swift
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
import SwiftyJSON

final class BusLineWaitTimeAtStopItem: JSONable, JSONCollection {

    let lineNumber: Int!
    let variantNumber: Int!
    let groupNumber: Int!
    let locationNumber: Int!
    let waitTime: Int!
    let busStopOfTrip: Int!

    required init(parameter: JSON) {
        self.lineNumber = parameter["LI_NR"].intValue
        self.variantNumber = parameter["STR_LI_VAR"].intValue
        self.groupNumber = parameter["FGR_NR"].intValue
        self.locationNumber = parameter["ORT_NR"].intValue
        self.waitTime = parameter["LIVAR_HZT_ZEIT"].intValue
        self.busStopOfTrip = parameter["LI_LFD_NR"].intValue
    }

    static func collection(parameter: JSON) -> [BusLineWaitTimeAtStopItem] {
        var items: [BusLineWaitTimeAtStopItem] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(BusLineWaitTimeAtStopItem(parameter: itemRepresentation))
        }

        return items
    }
}
