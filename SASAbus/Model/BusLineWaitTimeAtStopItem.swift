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

final class BusLineWaitTimeAtStopItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    
    private let lineNumber: Int!
    private let variantNumber: Int!
    private let groupNumber: Int!
    private let locationNumber: Int!
    private let waitTime: Int!
    private let busStopOfTrip: Int!
    
    init?( representation: AnyObject) {
        self.lineNumber = Int(representation.valueForKeyPath("LI_NR") as! String)!
        self.variantNumber = Int(representation.valueForKeyPath("STR_LI_VAR") as! String)!
        self.groupNumber = Int(representation.valueForKeyPath("FGR_NR") as! String)!
        self.locationNumber = Int(representation.valueForKeyPath("ORT_NR") as! String)!
        self.waitTime = Int(representation.valueForKeyPath("LIVAR_HZT_ZEIT") as! String)!
        self.busStopOfTrip = Int(representation.valueForKeyPath("LI_LFD_NR") as! String)!
    }
    
    
    static func collection(representation: AnyObject) -> [BusLineWaitTimeAtStopItem] {
        var items: [BusLineWaitTimeAtStopItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = BusLineWaitTimeAtStopItem(representation: itemRepresentation) {
                    items.append(item)
                }
            }
        }
        
        return items
    }
    
    func getLineNumber() -> Int {
        return self.lineNumber
    }
    
    func getVariantNumber() -> Int {
        return self.variantNumber
    }
    
    func getGroupNumber() -> Int {
        return self.groupNumber
    }
    
    func getLocationNumber() -> Int {
        return self.locationNumber
    }
    
    func getWaitTime() -> Int {
        return self.waitTime
    }
    
    func getBusStopOfTrip() -> Int {
        return self.busStopOfTrip
    }
}