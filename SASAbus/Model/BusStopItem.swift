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

final class BusStopItem: NSObject, NSCoding, ResponseObjectSerializable, ResponseCollectionSerializable {
    private var number: Int!
    private var location: CLLocation!
    
    required init?(coder aDecoder: NSCoder) {
        self.number = aDecoder.decodeObjectForKey("number") as! Int
        self.location = aDecoder.decodeObjectForKey("location") as! CLLocation
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.number, forKey: "number")
        aCoder.encodeObject(self.location, forKey: "location")
    }
    
    init?( representation: AnyObject) {
        super.init()
        self.number = representation.valueForKeyPath("ORT_NR") as! Int
        let latitude: CLLocationDegrees = representation.valueForKeyPath("ORT_POS_BREITE") as! Double
        let longitude: CLLocationDegrees = representation.valueForKeyPath("ORT_POS_LAENGE") as! Double
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    static func collection(representation: AnyObject) -> [BusStopItem] {
        var busStopItems: [BusStopItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for busStopRepresentation in representation {
                if let busStopItem = BusStopItem(representation: busStopRepresentation) {
                    busStopItems.append(busStopItem)
                }
            }
        }
        
        return busStopItems
    }
    
    func getNumber() -> Int {
        return self.number
    }
    
    func getLocation() -> CLLocation {
        return self.location
    }
    
    func getDictionary() -> Dictionary<String, AnyObject> {
        var jsonDictinary = [String: AnyObject]()
        jsonDictinary["ORT_NR"] = self.number
        jsonDictinary["ORT_POS_BREITE"] = self.location.coordinate.latitude
        jsonDictinary["ORT_POS_LAENGE"] = self.location.coordinate.longitude
        return jsonDictinary
    }
}