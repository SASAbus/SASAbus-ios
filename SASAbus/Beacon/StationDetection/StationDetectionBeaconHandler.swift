//
// StationDetectionBeaconHandler.swift
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
import Alamofire
import CoreLocation

class StationDetectionBeaconHandler:BeaconHandlerProtocol {
    
    let uuid:String
    let identifier:String
    
    init( uuid:String, identifier:String) {
        self.uuid = uuid
        self.identifier = identifier
    }
    
    func getUuid() -> String {
        return self.uuid
    }
    
    func getIdentifier() -> String {
        return self.identifier
    }
    
    func beaconsInRange(beacons: [CLBeacon]) {
        var nearestBeacon:CLBeacon? = nil
        for beacon in beacons {
            if nearestBeacon == nil ||
                (beacon.accuracy > 0 &&
                beacon.accuracy < nearestBeacon!.accuracy) {
                nearestBeacon = beacon
            }
        }
        if nearestBeacon != nil {
            self.beaconInRange(Int(nearestBeacon!.major), minor: Int(nearestBeacon!.minor))
        }
    }
    
    func beaconInRange(major:Int , minor:Int) {
        UserDefaultHelper.instance.setCurrentBusStopId(major);
    }
    
    func clearBeacons() {
        UserDefaultHelper.instance.setCurrentBusStopId(nil);
    }
    
    func inspectBeacons() {
        UserDefaultHelper.instance.setCurrentBusStopId(nil);
    }
    
    func handlerIsActive() -> Bool {
        return UserDefaultHelper.instance.isBeaconStationDetectionEnabled()
    }
}