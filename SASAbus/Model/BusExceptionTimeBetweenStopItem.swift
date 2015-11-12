//
// BusExceptionTimeBetweenStopItem.swift
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

final class BusExceptionTimeBetweenStopItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    
    private let tripId: Int!
    private let locationNumber: Int!
    private let exceptionTime: Int!
    
    init?( representation: AnyObject) {
        self.tripId = Int(representation.valueForKeyPath("FRT_FID") as! String)!
        self.locationNumber = Int(representation.valueForKeyPath("ORT_NR") as! String)!
        self.exceptionTime = Int(representation.valueForKeyPath("FRT_FZT_ZEIT") as! String)!
    }
    
    
    static func collection(representation: AnyObject) -> [BusExceptionTimeBetweenStopItem] {
        var busExceptionTimeBetweenStopItems: [BusExceptionTimeBetweenStopItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for busExceptionTimeBetweenStopRepresentation in representation {
                if let busExceptionTimeBetweenStopItem = BusExceptionTimeBetweenStopItem(representation: busExceptionTimeBetweenStopRepresentation) {
                    busExceptionTimeBetweenStopItems.append(busExceptionTimeBetweenStopItem)
                }
            }
        }
        
        return busExceptionTimeBetweenStopItems
    }
    
    func getTripId() -> Int {
        return self.tripId
    }
    
    func getLocationNumber() -> Int {
        return self.locationNumber
    }
    
    func getExceptionTime() -> Int {
        return self.exceptionTime
    }
}