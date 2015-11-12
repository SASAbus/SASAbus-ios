//
// BusTripItem.swift
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

final class BusTripItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    
    private let tripId: Int!
    private let startTime: Int!
    private let groupNumber: Int!
    
    init?( representation: AnyObject) {
        self.tripId = representation.valueForKeyPath("FRT_FID") as! Int
        self.startTime = representation.valueForKeyPath("FRT_START") as! Int
        self.groupNumber = representation.valueForKeyPath("FGR_NR") as! Int
    }
    
    
    static func collection(representation: AnyObject) -> [BusTripItem] {
        var busTripItems: [BusTripItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for busTripRepresentation in representation {
                if let busTripItem = BusTripItem(representation: busTripRepresentation) {
                    busTripItems.append(busTripItem)
                }
            }
        }
        
        return busTripItems
    }
    
    func getTripId() -> Int {
        return self.tripId
    }
    
    func getStartTime() -> Int {
        return self.startTime
    }
    
    func getGroupNumber() -> Int {
        return self.groupNumber
    }
}