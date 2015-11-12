//
// BusDayTypeItem.swift
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

final class BusDayTypeItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    private let date: NSDate!
    private let dayTypeNumber: Int!
    
    init?( representation: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.date = dateFormatter.dateFromString(representation.valueForKeyPath("BETRIEBSTAG") as! String)
        self.dayTypeNumber = Int(representation.valueForKeyPath("TAGESART_NR") as! String)
    }
    
    static func collection(representation: AnyObject) -> [BusDayTypeItem] {
        var items: [BusDayTypeItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = BusDayTypeItem(representation: itemRepresentation) {
                    items.append(item)
                }
            }
        }
        return items
    }
    
    func getDate() -> NSDate {
        return self.date
    }
    
    func getDayTypeNumber() -> Int {
        return self.dayTypeNumber
    }
}
