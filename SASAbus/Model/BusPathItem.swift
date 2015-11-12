//
// BusPathItem.swift
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

final class BusPathItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    private let lineNumber: Int!
    private let variants: [BusPathVariantItem]!
    
    init?( representation: AnyObject) {
        self.lineNumber = Int(representation.valueForKeyPath("LI_NR") as! String)
        self.variants = BusPathVariantItem.collection(representation.valueForKeyPath("varlist")!)
        
    }
    
    static func collection(representation: AnyObject) -> [BusPathItem] {
        var items: [BusPathItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = BusPathItem(representation: itemRepresentation) {
                    items.append(item)
                }
            }
        }
        return items
    }
    
    func getLineNumber() -> Int {
        return self.lineNumber
    }
    
    func getVariants() -> [BusPathVariantItem]! {
        return self.variants
    }
}