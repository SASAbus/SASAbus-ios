//
// BusLineItem.swift
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

import UIKit

final class BusLineItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    private let shortName: String!
    private let name: String!
    private let variants: [Int]!
    private let number: Int!
    
    init?( representation: AnyObject) {
        self.shortName = representation.valueForKeyPath("LI_KUERZEL") as! String
        self.name = representation.valueForKeyPath("LIDNAME") as! String
        self.variants = representation.valueForKeyPath("varlist") as! [Int]
        self.number = representation.valueForKeyPath("LI_NR") as! Int
    }
    
    init?(shortName: String, name: String, variants: [Int], number: Int) {
        self.shortName = shortName
        self.name = name
        self.variants = variants
        self.number = number
    }
    
    static func collection(representation: AnyObject) -> [BusLineItem] {
        var busLineItems: [BusLineItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for busLineRepresentation in representation {
                if let busLineItem = BusLineItem(representation: busLineRepresentation) {
                    busLineItems.append(busLineItem)
                }
            }
        }
        
        return busLineItems
    }
    
    func getShortName() -> String {
        return self.shortName
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getVariants() -> [Int] {
        return self.variants
    }
    
    func getNumber() -> Int {
        return self.number
    }
    
    func getArea() -> String {
        let shortNameParts = self.getShortName().characters.split {$0 == " "}
        switch String(shortNameParts[0]) {
        case "201":
            return "OTHER"
        case "248":
            return "OTHER"
        case "300":
            return "OTHER"
        case "5000":
            return "OTHER"
        case "227":
            return "ME"
        default:
            break
        }
        if shortNameParts.count > 1 {
            return String(shortNameParts[1])
        } else {
            return "OTHER"
        }
    }
}