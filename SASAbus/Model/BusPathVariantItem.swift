//
// BusPathVariantItem.swift
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

final class BusPathVariantItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    private let variantNumber: Int!
    private let busStops:[Int]!
    
    init?( representation: AnyObject) {
        self.variantNumber = representation.valueForKeyPath("STR_LI_VAR") as! Int
        self.busStops = representation.valueForKeyPath("routelist") as! [Int]!
        
    }
    
    static func collection(representation: AnyObject) -> [BusPathVariantItem] {
        var items: [BusPathVariantItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = BusPathVariantItem(representation: itemRepresentation) {
                    items.append(item)
                }
            }
        }
        return items
    }
    
    func getVariantNumber() -> Int {
        return self.variantNumber
    }
    
    func getBusStops() -> [Int] {
        return self.busStops
    }
}