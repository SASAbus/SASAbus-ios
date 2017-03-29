//
// BusTripVariantItem.swift
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

final class BusTripVariantItem: JSONable, JSONCollection {

    let variant: Int
    let trips: [BusTripItem]

    required init(parameter: JSON) {
        self.variant = parameter["STR_LI_VAR"].intValue
        self.trips = BusTripItem.collection(parameter: parameter["triplist"])
    }

    static func collection(parameter: JSON) -> [BusTripVariantItem] {
        var items: [BusTripVariantItem] = []

        for trip in parameter.arrayValue {
            items.append(BusTripVariantItem(parameter: trip))
        }

        return items
    }
}
