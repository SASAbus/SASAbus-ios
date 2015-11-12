//
// PositionItem.swift
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
import CoreLocation
import UIKit

final class PositionItem: ResponseObjectSerializable, ResponseCollectionSerializable {
    
    private let tripId: Int!
    private let gpsDate: NSDate!
    private let delay: Int!
    private let vehicleCode: String!
    private let lineNumber: Int!
    private let variantNumber: Int!
    private let lineName: String!
    private let insertDate: NSDate!
    private var lineColorRGB: UIColor!
    private let nextStopNumber: Int!
    private let nextStopType: Int!
    private let nextStopName: String!
    private let nextStopFullName: String!
    private let lineColorHex: String!
    private let lineColorHexWithoutHashTag: String!
    private let coordinates: CLLocation!
    private var locationNumber: Int?
    
    init?( representation: AnyObject) {
        self.tripId = representation.valueForKeyPath("properties")?.valueForKeyPath("frt_fid") as! Int
        let gpsDateFormatter = NSDateFormatter()
        gpsDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        self.gpsDate = gpsDateFormatter.dateFromString(representation.valueForKeyPath("properties")?.valueForKeyPath("gps_date") as! String)
        let delay = representation.valueForKeyPath("properties")?.valueForKeyPath("delay_sec") as? Int
        if (delay != nil) {
            self.delay = delay
        } else {
            self.delay = 0
        }
        self.vehicleCode = representation.valueForKeyPath("properties")?.valueForKeyPath("vehiclecode") as! String
        self.lineNumber = representation.valueForKeyPath("properties")?.valueForKeyPath("li_nr") as! Int
        self.variantNumber = Int((representation.valueForKeyPath("properties")?.valueForKeyPath("str_li_var") as! String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
        self.lineName = representation.valueForKeyPath("properties")?.valueForKeyPath("lidname") as! String
        let insertDateFormatter = NSDateFormatter()
        insertDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.insertDate = insertDateFormatter.dateFromString(representation.valueForKeyPath("properties")?.valueForKeyPath("insert_date") as! String)
        let lineColorRedString = representation.valueForKeyPath("properties")?.valueForKeyPath("li_r") as? String
        self.lineColorRGB = nil
        if (lineColorRedString != nil) {
            let lineColorRed = CGFloat(representation.valueForKeyPath("properties")?.valueForKeyPath("li_r") as! Int)
            let lineColorGreen = CGFloat(representation.valueForKeyPath("properties")?.valueForKeyPath("li_g") as! Int)
            let lineColorBlue = CGFloat(representation.valueForKeyPath("properties")?.valueForKeyPath("li_g") as! Int)
            self.lineColorRGB = UIColor(red: lineColorRed, green: lineColorGreen, blue: lineColorBlue, alpha: 1)
        }
        self.nextStopNumber = representation.valueForKeyPath("properties")?.valueForKeyPath("ort_nr") as! Int
        self.nextStopType = representation.valueForKeyPath("properties")?.valueForKeyPath("onr_typ_nr") as! Int
        self.nextStopName = representation.valueForKeyPath("properties")?.valueForKeyPath("ort_name") as! String
        self.nextStopFullName = representation.valueForKeyPath("properties")?.valueForKeyPath("ort_ref_ort_name") as! String
        self.lineColorHex = representation.valueForKeyPath("properties")?.valueForKeyPath("hexcolor") as! String
        self.lineColorHexWithoutHashTag = representation.valueForKeyPath("properties")?.valueForKeyPath("hexcolor2") as! String
        let longitude = representation.valueForKeyPath("geometry")?.valueForKeyPath("coordinates")?[0] as! Double
        let latitude = representation.valueForKeyPath("geometry")?.valueForKeyPath("coordinates")?[1] as! Double
        self.coordinates = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    static func collection(representation: AnyObject) -> [PositionItem] {
        var items: [PositionItem] = []
        
        if let representation = representation.valueForKeyPath("features") as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = PositionItem(representation: itemRepresentation) {
                    items.append(item)
                }
            }
        }
        
        return items
    }
    
    func getTripId() -> Int {
        return self.tripId
    }
    
    func getGpsDate() -> NSDate {
        return self.gpsDate
    }
    
    func getDelay() -> Int {
        return self.delay
    }
    
    func getDelayRoundedToMinutes() -> Int {
        var delay = self.delay
        if (delay < 0) {
            delay = delay - 59
        }
        return delay / 60
    }
    
    func getVehicleCode() -> String {
        return self.getVehicleCode()
    }
    
    func getLineNumber() -> Int {
        return self.lineNumber
    }
    
    func getVariantNumber() -> Int {
        return self.variantNumber
    }
    
    func getLineName() -> String? {
        return self.lineName
    }
    
    func getInsertDate() -> NSDate {
        return self.insertDate
    }
    
    func getLineColor() -> UIColor {
        return self.lineColorRGB
    }
    
    func getNextStopNumber() -> Int {
        return self.nextStopNumber
    }
    
    func getNextStopType() -> Int {
        return self.nextStopType
    }
    
    func getNextStopName() -> String {
        return self.nextStopName
    }
    
    func getNextStopFullName() -> String {
        return self.nextStopFullName
    }
    
    func getLineColorHex() -> String {
        return self.lineColorHex
    }
    
    func getLineColorHexWithoutHashTag() -> String {
        return self.lineColorHexWithoutHashTag
    }
    
    func getCoordinates() -> CLLocation {
        return self.coordinates
    }
    
    func getLocationNumber() -> Int? {
        return self.locationNumber
    }
    
    func setLocationNumber(locationNumber: Int) {
        self.locationNumber = locationNumber
    }
}