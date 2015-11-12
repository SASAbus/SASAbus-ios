//
// BusStationItem.swift
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

final class BusStationItem: NSObject, NSCoding, ResponseObjectSerializable, ResponseCollectionSerializable {
    private var community: String!
    private var name: String!
    private var busStops: [BusStopItem]!
    private var descriptionDe: String!
    private var descriptionIt: String!
    private var busLineIds: [Int]!
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.community, forKey: "community")
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.busStops, forKey: "busStops")
        aCoder.encodeObject(self.descriptionDe, forKey: "descriptionDe")
        aCoder.encodeObject(self.descriptionIt, forKey: "descriptionIt")
        aCoder.encodeObject(self.busLineIds, forKey: "busLineIds")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.community = aDecoder.decodeObjectForKey("community") as! String
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.busStops = aDecoder.decodeObjectForKey("busStops") as! [BusStopItem]
        self.descriptionDe = aDecoder.decodeObjectForKey("descriptionDe") as! String
        self.descriptionIt = aDecoder.decodeObjectForKey("descriptionIt") as! String
        self.busLineIds = aDecoder.decodeObjectForKey("busLineIds") as! [Int]
    }
    
    init?( representation: AnyObject) {
        super.init()
        self.community = representation.valueForKeyPath("ORT_GEMEINDE") as! String
        self.name = representation.valueForKeyPath("ORT_NAME") as! String
        self.busStops = BusStopItem.collection(representation.valueForKeyPath("busstops")!)
        self.busLineIds = representation.valueForKeyPath("busLineIds") as! [Int]!
        if self.busLineIds == nil {
            self.busLineIds = []
        }
        self.generateDescription()
    }
    
    static func collection(representation: AnyObject) -> [BusStationItem] {
        var busStationItems: [BusStationItem] = []
        
        if let representation = representation as? [[String: AnyObject]] {
            for busStationRepresentation in representation {
                if let busStationItem = BusStationItem(representation: busStationRepresentation) {
                    busStationItems.append(busStationItem)
                }
            }
        }
        return busStationItems
    }
    
    func getCommunity() -> String {
        return self.community
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getBusStops() -> [BusStopItem] {
        return self.busStops
    }
    
    func containsBusStop(busStopId: Int) -> Bool {
        return (self.busStops.find({$0.getNumber() == busStopId}) != nil)
    }
    
    func getDescription() -> String {
        var description = self.descriptionDe
        if NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String == "it" {
            description = self.descriptionIt
        }
        return description
    }
    
    func addBusLineId(number: Int) {
        if !self.busLineIds.contains(number) {
            self.busLineIds.append(number)
        }
    }
    
    func getBusLines() -> [BusLineItem] {
        let busLines: [BusLineItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusLines) as [BusLineItem]
        var stationBusLines: [BusLineItem] = []
        for busLineId in self.busLineIds {
            let busLine: BusLineItem? = busLines.find({$0.getNumber() == busLineId})
            if (busLine != nil) {
                stationBusLines.append(busLine!)
            }
        }
        return stationBusLines
    }
    
    private func generateDescription() {
        self.descriptionIt = self.name
        self.descriptionDe = self.name
        let locationNames = self.name.characters.split {$0 == "-"}
        if (locationNames.count > 1) {
            self.descriptionIt = String(locationNames[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.descriptionDe = String(locationNames[1]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
        let communityNames = self.community.characters.split {$0 == "-"}
        self.descriptionIt = self.descriptionIt + " (" + String(communityNames[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + ")"
        self.descriptionDe = self.descriptionDe + " (" + String(communityNames[1]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + ")"
    }
    
    func getDictionary() -> Dictionary<String, AnyObject> {
        var jsonDictinary = [String: AnyObject]()
        jsonDictinary["ORT_GEMEINDE"] = self.community
        jsonDictinary["ORT_NAME"] = self.name
        jsonDictinary["busLineIds"] = self.busLineIds

        var busStops = [Dictionary<String, AnyObject>]()
        for busStop in self.busStops {
            busStops.append(busStop.getDictionary())
        }
        jsonDictinary["busstops"] = busStops
        return jsonDictinary
    }
}