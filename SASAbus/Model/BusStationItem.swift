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
import SwiftyJSON

final class BusStationItem: NSCoding, JSONable, JSONCollection {

    var community: String!
    var name: String!
    var busStops: [BusStopItem]!
    var descriptionDe: String!
    var descriptionIt: String!
    var busLineIds: [Int]!


    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.community, forKey: "community")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.busStops, forKey: "busStops")
        aCoder.encode(self.descriptionDe, forKey: "descriptionDe")
        aCoder.encode(self.descriptionIt, forKey: "descriptionIt")
        aCoder.encode(self.busLineIds, forKey: "busLineIds")
    }

    required init?(coder aDecoder: NSCoder) {
        self.community = aDecoder.decodeObject(forKey: "community") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.busStops = aDecoder.decodeObject(forKey: "busStops") as! [BusStopItem]
        self.descriptionDe = aDecoder.decodeObject(forKey: "descriptionDe") as! String
        self.descriptionIt = aDecoder.decodeObject(forKey: "descriptionIt") as! String
        self.busLineIds = aDecoder.decodeObject(forKey: "busLineIds") as! [Int]
    }

    required init(parameter: JSON) {
        self.community = parameter["ORT_GEMEINDE"].stringValue
        self.name = parameter["ORT_NAME"].stringValue

        self.busStops = BusStopItem.collection(parameter: parameter["busstops"])

        self.busLineIds = parameter["busLineIds"].arrayValue.map {
            $0.intValue
        }

        if self.busLineIds == nil {
            self.busLineIds = []
        }

        self.generateDescription()
    }

    static func collection(parameter: JSON) -> [BusStationItem] {
        var items: [BusStationItem] = []

        for busStop in parameter.arrayValue {
            items.append(BusStationItem(parameter: busStop))
        }

        return items
    }

    func containsBusStop(_ busStopId: Int) -> Bool {
        return (self.busStops.find({ $0.number == busStopId }) != nil)
    }

    func getDescription() -> String {
        var description = self.descriptionDe
        if (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String == "it" {
            description = self.descriptionIt
        }
        return description!
    }

    func addBusLineId(_ number: Int) {
        if !self.busLineIds.contains(number) {
            self.busLineIds.append(number)
        }
    }

    func getBusLines() -> [Line] {
        let busLines: [Line] = SasaDataHelper.getData(SasaDataHelper.REC_LID)
        var stationBusLines: [Line] = []

        for busLineId in self.busLineIds {
            let busLine: Line? = busLines.find {
                $0.id == busLineId
            }

            if (busLine != nil) {
                stationBusLines.append(busLine!)
            }
        }

        return stationBusLines
    }

    fileprivate func generateDescription() {
        self.descriptionIt = self.name
        self.descriptionDe = self.name

        let locationNames = self.name.characters.split {
            $0 == "-"
        }

        if (locationNames.count > 1) {
            self.descriptionIt = String(locationNames[0]).trimmingCharacters(in: CharacterSet.whitespaces)
            self.descriptionDe = String(locationNames[1]).trimmingCharacters(in: CharacterSet.whitespaces)
        }

        let communityNames = self.community.characters.split {
            $0 == "-"
        }

        self.descriptionIt = self.descriptionIt + " (" + String(communityNames[0]).trimmingCharacters(in: CharacterSet.whitespaces) + ")"
        self.descriptionDe = self.descriptionDe + " (" + String(communityNames[1]).trimmingCharacters(in: CharacterSet.whitespaces) + ")"
    }

    func getDictionary() -> Dictionary<String, AnyObject> {
        var jsonDictinary = [String: AnyObject]()

        jsonDictinary["ORT_GEMEINDE"] = self.community as AnyObject?
        jsonDictinary["ORT_NAME"] = self.name as AnyObject?
        jsonDictinary["busLineIds"] = self.busLineIds as AnyObject?

        var busStops = [Dictionary<String, AnyObject>]()
        for busStop in self.busStops {
            busStops.append(busStop.getDictionary())
        }

        jsonDictinary["busstops"] = busStops as AnyObject?
        return jsonDictinary
    }
}
