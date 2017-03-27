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

    var lastSeen: Date!
    var startDate: Date
    var seconds: Int! = 0
    var locationTime: Int
    var uuid: String
    var major: Int
    var minor: Int
    var positionItem: RealtimeBus?
    var location: CLLocation?
    var stopPositionItem: RealtimeBus?

    init(uuid: String, major: Int, minor: Int, time: Int) {
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.locationTime = time
        self.startDate = Date()
        self.lastSeen = startDate
    }

    func seen() {
        let now = Date()
        self.seconds = Int(now.timeIntervalSince1970) - Int(self.startDate.timeIntervalSince1970);
        self.lastSeen = now
    }

    func setBusInformation(_ positionItem: RealtimeBus) {
        self.positionItem = positionItem
        self.location = positionItem.getCoordinates()
    }

    func getLineName() -> String? {
        var lineName: String? = nil
        if positionItem != nil {
            lineName = (positionItem?.lineName)!
        }
        return lineName
    }

    func getTripId() -> Int? {
        var tripId: Int? = nil
        if positionItem != nil {
            tripId = (positionItem?.trip)!
        }
        return tripId
    }

    func getStartBusStop() -> Int? {
        var busStop: Int? = nil
        if positionItem != nil {
            busStop = (positionItem?.busStop)!
        }
        return busStop
    }

    func getStopBusStop() -> Int? {
        var stopBusStop: Int? = nil
        if stopPositionItem != nil {
            stopBusStop = (stopPositionItem?.busStop)!
        }
        return stopBusStop
    }
}
