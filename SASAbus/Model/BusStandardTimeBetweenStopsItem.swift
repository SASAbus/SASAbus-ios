//
// BusStandardTimeBetweenStopItem.swift
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

final class BusStandardTimeBetweenStopItem: JSONable, JSONCollection {

    let groupNumber: Int!
    let locationNumber: Int!
    let standardTime: Int!
    let destination: Int!

    let locationDestinationGroupIdentifier: String!

    required init(parameter: JSON) {
        self.groupNumber = parameter["FGR_NR"].intValue
        self.locationNumber = parameter["ORT_NR"].intValue

        self.standardTime = parameter["SEL_FZT"].intValue
        self.destination = parameter["SEL_ZIEL"].intValue

        self.locationDestinationGroupIdentifier = [
                String(self.locationNumber),
                String(self.destination),
                String(self.groupNumber)
        ].joined(separator: ":")
    }


    static func collection(parameter: JSON) -> [BusStandardTimeBetweenStopItem] {
        var items: [BusStandardTimeBetweenStopItem] = []

        for standardTime in parameter.arrayValue {
            items.append(BusStandardTimeBetweenStopItem(parameter: standardTime))
        }

        return items
    }
}
