//
// BusDayTypeTripItem.swift
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

final class BusDayTypeTripItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    private let busLineId: Int!
    private let dayTypeId: Int!
    private let busTripVariants: [BusTripVariantItem]!
    
    init?( representation: AnyObject) {
        self.busLineId = Int(representation.valueForKeyPath("LI_NR") as! String)!
        let dayTypeList = representation.valueForKeyPath("tagesartlist") as! NSArray
        self.dayTypeId = dayTypeList[0].valueForKeyPath("TAGESART_NR") as! Int
        self.busTripVariants = BusTripVariantItem.collection(dayTypeList[0].valueForKeyPath("varlist")!)
    }
    
    static func collection(representation: AnyObject) -> [BusDayTypeTripItem] {
        var busDayTypeTripItems: [BusDayTypeTripItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for busDayTypeTripRepresentation in representation {
                if let busDayTypeTripItem = BusDayTypeTripItem(representation: busDayTypeTripRepresentation) {
                    busDayTypeTripItems.append(busDayTypeTripItem)
                }
            }
        }
        
        return busDayTypeTripItems
    }
    
    func getBusLineId() -> Int {
        return self.busLineId
    }
    
    func getDayTypeId() -> Int {
        return self.dayTypeId
    }
    
    func getBusTripVariants() -> [BusTripVariantItem] {
        return self.busTripVariants
    }
}