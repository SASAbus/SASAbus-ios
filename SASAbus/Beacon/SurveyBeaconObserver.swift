//
// SurveyBeaconObserver.swift
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

import CoreLocation
import Alamofire
import UIKit

class SurveyBeaconObserver: NSObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    private var region:CLBeaconRegion!
    private var beaconHandler:BeaconHandlerProtocol!
    private var regions:Dictionary<String, CLBeaconRegion> =  Dictionary<String, CLBeaconRegion>()
    private var didEnterRegionDate:NSDate? = nil
    private var didExitRegionDate:NSDate? = nil
    
    
    init(beaconHandler:BeaconHandlerProtocol) {
        super.init()
        self.locationManager.delegate = self
        self.beaconHandler = beaconHandler
        
        self.region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: beaconHandler.getUuid())!, identifier: beaconHandler.getIdentifier())
        self.region.notifyEntryStateOnDisplay = true
        self.region.notifyOnEntry = true;
        self.region.notifyOnExit = true;
    }
    
    func startObserving() {
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways) {
            locationManager.requestAlwaysAuthorization()
        }

        LogHelper.instance.log("Monitoring for " + self.region.proximityUUID.UUIDString)
        locationManager.startMonitoringForRegion(self.region)
        locationManager.startRangingBeaconsInRegion(self.region)
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.Unknown }
        if knownBeacons.count > 0 {
            LogHelper.instance.log("update \( beaconHandler.getUuid())")
            for knownBeacon in knownBeacons{
                let major = CLBeaconMajorValue(Int(knownBeacon.major))
                let key:String = "\(beaconHandler.getUuid())_\(major)"
                let identifier:String = "\(beaconHandler.getIdentifier())_\(major)"
                
                if !self.regions.keys.contains(key) {
                    let newRegion =  CLBeaconRegion(proximityUUID: NSUUID(UUIDString: beaconHandler.getUuid())!,major:major, identifier: identifier)
                    newRegion.notifyOnEntry = false
                    newRegion.notifyOnExit = true
                    self.locationManager.startMonitoringForRegion(newRegion)
                    self.regions[key] = newRegion
                }
                
            }
            self.beaconHandler.beaconsInRange(knownBeacons)
        }
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {

        let now = NSDate()
        if didEnterRegionDate == nil || (now.timeIntervalSince1970 - (didEnterRegionDate?.timeIntervalSince1970)!) > 2  {
            didEnterRegionDate = now
            print("didEnterRegion \( beaconHandler.getUuid())")
            self.beaconHandler.clearBeacons();
            locationManager.startRangingBeaconsInRegion(self.region)
        }
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        let beaconRegion = region as! CLBeaconRegion
        if (beaconRegion.major != nil ) {
            let now = NSDate()
            if didExitRegionDate == nil || (now.timeIntervalSince1970 - (didExitRegionDate?.timeIntervalSince1970)!) > 2  {
                didExitRegionDate = now
                print("didExitRegion \( beaconHandler.getUuid()) \(beaconRegion.major)")
                let key:String = "\(beaconHandler.getUuid())_\(beaconRegion.major!)"
                let newRegion = self.regions.removeValueForKey(key)
                if newRegion != nil {
                    self.locationManager.stopMonitoringForRegion(newRegion!)
                }
                self.beaconHandler.beaconInRange(Int(beaconRegion.major!), minor: 0)
                
                if self.regions.count == 0 {
                    self.beaconHandler.inspectBeacons();
                    locationManager.stopRangingBeaconsInRegion(self.region)
                }
                
            }
        }
    }
}