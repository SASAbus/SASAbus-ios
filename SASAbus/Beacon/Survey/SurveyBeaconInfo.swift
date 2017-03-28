//
// SurveyBeaconInfo.swift
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

class SurveyBeaconInfo {
    
    var lastSeen: NSDate!
    var startDate: NSDate
    var seconds: Int! = 0
    var locationTime: Int
    var uuid: String
    var major: Int
    var minor: Int
    var positionItem: PositionItem?
    var location: CLLocation?
    var stopPositionItem: PositionItem?
    
    init(uuid:String, major:Int, minor:Int, time:Int) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.locationTime = time
        self.startDate = NSDate();
        self.lastSeen = startDate
    }
    
    func seen() {
        let now = NSDate();
        self.seconds = Int(now.timeIntervalSince1970) - Int(self.startDate.timeIntervalSince1970)
        self.lastSeen = now
    }
    
    func setBusInformation(positionItem:PositionItem) {
        self.positionItem = positionItem
        self.location = positionItem.getCoordinates()
    }
    
    func setLocation(location:CLLocation) {
        self.location = location
    }
    
    func getLastSeen() -> NSDate {
        return self.lastSeen
    }
    
    func getLocation() -> CLLocation? {
        return self.location
    }
    
    func getSeenSeconds() -> Int {
        return self.seconds
    }
    
    func getLineName() -> String? {
        var lineName:String? = nil
        if positionItem != nil {
            lineName = (positionItem?.getLineName())!
        }
        return lineName
    }
    
    func getTripId() -> Int? {
        var tripId:Int? = nil
        if positionItem != nil {
            tripId = (positionItem?.getTripId())!
        }
        return tripId
    }
    
    func getMajor() -> Int {
        return self.major
    }
    
    
    func getMinor() -> Int {
        return self.minor
    }
    
    func getStartBusStop() -> Int? {
        var busStop:Int? = nil
        if positionItem != nil {
            busStop = (positionItem?.getNextStopNumber())!
        }
        return busStop
    }
    
    func setStopPosition(positionItem:PositionItem) {
        self.stopPositionItem = positionItem
    }
    
    func getStopBusStop() -> Int? {
        var stopBusStop:Int? = nil
        if stopPositionItem != nil {
            stopBusStop = (stopPositionItem?.getNextStopNumber())!
        }
        return stopBusStop
    }
}
