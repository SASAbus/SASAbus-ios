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

final class BusStandardTimeBetweenStopItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    
    private let groupNumber: Int!
    private let locationNumber: Int!
    private let standardTime: Int!
    private let destination: Int!
    private let locationDestinationGroupIdentifier: String
    
    init?( representation: AnyObject) {
        self.groupNumber = Int(representation.valueForKeyPath("FGR_NR") as! String)!
        self.locationNumber = Int(representation.valueForKeyPath("ORT_NR") as! String)!
        self.standardTime = Int(representation.valueForKeyPath("SEL_FZT") as! String)!
        self.destination = Int(representation.valueForKeyPath("SEL_ZIEL") as! String)!
        self.locationDestinationGroupIdentifier = [
            String(self.locationNumber),
            String(self.destination),
            String(self.groupNumber)
            ].joinWithSeparator(":")
    }
    
    
    static func collection(representation: AnyObject) -> [BusStandardTimeBetweenStopItem] {
        var busStandardTimeBetweenStopItems: [BusStandardTimeBetweenStopItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for busStandardTimeBetweenStopRepresentation in representation {
                if let busStandardTimeBetweenStopItem = BusStandardTimeBetweenStopItem(representation: busStandardTimeBetweenStopRepresentation) {
                    busStandardTimeBetweenStopItems.append(busStandardTimeBetweenStopItem)
                }
            }
        }
        
        return busStandardTimeBetweenStopItems
    }
    
    func getGroupNumber() -> Int {
        return self.groupNumber
    }
    
    func getLocationNumber() -> Int {
        return self.locationNumber
    }
    
    func getStandardTime() -> Int {
        return self.standardTime
    }
    
    func getDestination() -> Int {
        return self.destination
    }
    
    func getLocationDestinationGroupIdentifier() -> String {

        return self.locationDestinationGroupIdentifier
    }
}