//
// BusStopItem.swift
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

final class BusStopItem: NSObject, NSCoding, JSONable, JSONCollection {

    var number: Int!
    var location: CLLocation!

    required init?(coder aDecoder: NSCoder) {
        self.number = aDecoder.decodeObject(forKey: "number") as! Int
        self.location = aDecoder.decodeObject(forKey: "location") as! CLLocation
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.number, forKey: "number")
        aCoder.encode(self.location, forKey: "location")
    }

    required init(parameter: JSON) {
        super.init()

        self.number = parameter["ORT_NR"].intValue

        let latitude: CLLocationDegrees = parameter["ORT_POS_BREITE"].doubleValue
        let longitude: CLLocationDegrees = parameter["ORT_POS_LAENGE"].doubleValue

        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }

    static func collection(parameter: JSON) -> [BusStopItem] {
        var items: [BusStopItem] = []

        for busStop in parameter.arrayValue {
            items.append(BusStopItem(parameter: busStop))
        }

        return items
    }

    func getDictionary() -> [String : AnyObject] {
        var json = [String: AnyObject]()

        json["ORT_NR"] = self.number as AnyObject?
        json["ORT_POS_BREITE"] = self.location.coordinate.latitude as AnyObject?
        json["ORT_POS_LAENGE"] = self.location.coordinate.longitude as AnyObject?

        return json
    }
}
