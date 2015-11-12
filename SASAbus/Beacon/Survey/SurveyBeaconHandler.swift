//
// SurveyBeaconHandler.swift
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

class SurveyBeaconHandler:BeaconHandlerProtocol {
    
    var beaconLocationHandlerStart:SurveyLocationHandler?
    var beaconLocationHandlerStop:SurveyLocationHandler?
    var beaconsToObserve = [String : SurveyBeaconInfo]()
    let surveyAction:SurveyActionProtocol
    let uuid:String
    let identifier:String

    init(surveyAction:SurveyActionProtocol, uuid:String, identifier:String) {
        self.surveyAction = surveyAction
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
        for beacon in beacons {
            self.beaconInRange(Int(beacon.major), minor: Int(beacon.minor))
        }
    }
    
    func beaconInRange(major:Int , minor:Int) {
        let key:String = "\(self.uuid)_\(major)";
        
        if self.checkLastSurveyTime() == true {
            
            if beaconsToObserve.keys.contains(key) {
                let beaconInfo = beaconsToObserve[key] as SurveyBeaconInfo?
                beaconInfo!.seen()
                LogHelper.instance.log( "Beacon has been seen for " + (beaconInfo?.getSeenSeconds().description)!)
            }
            else {

                let beaconInfo = SurveyBeaconInfo(uuid: self.uuid, major: major, minor: minor, time: Int((NSDate()).timeIntervalSince1970));
                beaconsToObserve[key] = beaconInfo
                
                Alamofire.request(RealTimeDataApiRouter.GetPositionForVehiclecode(major)).responseCollection { (response: Response<[PositionItem], NSError>) in
                    
                    if (response.result.isSuccess) {
                        var positionItems = response.result.value
                        
                        if (positionItems != nil && positionItems?.count > 0) {
                            positionItems = positionItems!.sort({NSCalendar.currentCalendar().compareDate($0.getGpsDate(), toDate:$1.getGpsDate(), toUnitGranularity: NSCalendarUnit.Second) == NSComparisonResult.OrderedDescending })
                            beaconInfo.setBusInformation(positionItems![0])
                        } else {
                            //get location from device
                            self.beaconLocationHandlerStart = SurveyLocationHandler(locationFoundProtocol:StartLocationFound(beaconInfo: beaconInfo))
                            self.beaconLocationHandlerStart!.getLocationAsync()
                            
                        }
                    } else {
                        //get location from device
                        self.beaconLocationHandlerStart = SurveyLocationHandler(locationFoundProtocol:StartLocationFound(beaconInfo: beaconInfo))
                        self.beaconLocationHandlerStart!.getLocationAsync()
                    }
                }
            }
        }
    }
    
    func clearBeacons() {
        self.beaconsToObserve.removeAll()
    }
    
    func inspectBeacons() {
        let inspectBeaconGroup: dispatch_group_t = dispatch_group_create()
        
        for beacon in beaconsToObserve.values {
            dispatch_group_enter(inspectBeaconGroup)
            checkIfBeaconIsSuitableForSurvey(beacon, group: inspectBeaconGroup);
        }
        
        dispatch_group_notify(inspectBeaconGroup, dispatch_get_main_queue(), {
            self.clearBeacons();
        })
    }
    
    func handlerIsActive() -> Bool {
        return true
    }
    
    func checkIfBeaconIsSuitableForSurvey(beaconInfo:SurveyBeaconInfo, group:dispatch_group_t) {
        let now = NSDate()
        if (Int(beaconInfo.getLastSeen().timeIntervalSince1970) + Configuration.beaconLastSeenTreshold) > Int(now.timeIntervalSince1970) {
            Alamofire.request(RealTimeDataApiRouter.GetPositionForVehiclecode(beaconInfo.getMajor())).responseCollection { (response: Response<[PositionItem], NSError>) in
                
                if (response.result.isSuccess) {
                    var positionItems = response.result.value
                    
                    if (positionItems != nil && positionItems?.count > 0) {
                        positionItems = positionItems!.sort({NSCalendar.currentCalendar().compareDate($0.getGpsDate(), toDate:$1.getGpsDate(), toUnitGranularity: NSCalendarUnit.Second) == NSComparisonResult.OrderedAscending })
                        beaconInfo.setStopPosition(positionItems![0])
                        self.checkTrip(beaconInfo, location: positionItems![0].getCoordinates())
                        dispatch_group_leave(group)
                    } else {
                        //get location from device
                        dispatch_group_leave(group)
                        self.beaconLocationHandlerStop = SurveyLocationHandler(locationFoundProtocol:StopLocationFound(beaconInfo: beaconInfo, master:self))
                        self.beaconLocationHandlerStop!.getLocationAsync()
                    }
                } else {
                    //get location from device
                    dispatch_group_leave(group)
                    self.beaconLocationHandlerStop = SurveyLocationHandler(locationFoundProtocol:StopLocationFound(beaconInfo: beaconInfo, master:self))
                    self.beaconLocationHandlerStop!.getLocationAsync()
                }
            }
        }
    }
    
    private func checkTrip(beaconInfo:SurveyBeaconInfo, location:CLLocation) {
        if beaconInfo.getLocation() != nil {
            let distance = beaconInfo.getLocation()!.distanceFromLocation(location)
        
            if Int(distance) > Configuration.beaconMinTripDistance &&
                beaconInfo.getSeenSeconds() > Configuration.beaconSecondsInBus {
                    LogHelper.instance.log("trigger survey for "+beaconInfo.getMajor().description)
                    self.surveyAction.triggerSurvey(beaconInfo)
            } 
            
        }
    }
    
    private func checkLastSurveyTime() -> Bool {
        var result:Bool = true
        let lastSurveyTimeStamp = UserDefaultHelper.instance.getLastSurveyTimeStamp()
        if lastSurveyTimeStamp != nil {
            
            let lastSurveyDate = NSDate(timeIntervalSince1970: NSTimeInterval(lastSurveyTimeStamp!))
            let secondsLastSurvey = Int(lastSurveyDate.timeIntervalSince1970)
            let secondsNow = Int(NSDate().timeIntervalSince1970)
            let secondsBetweenSurvey = secondsNow - secondsLastSurvey;
            let prefSurveyRecurring = UserDefaultHelper.instance.getSurveyCycle()
            result = secondsBetweenSurvey > prefSurveyRecurring
        }   
        return result
    }
    
    
    private class StartLocationFound:LocationFoundProtocol {
        
        var beaconInfo:SurveyBeaconInfo!
        
        init(beaconInfo:SurveyBeaconInfo) {
            self.beaconInfo = beaconInfo
        }
        
        func found(location:CLLocation) {
            self.beaconInfo.setLocation(location)
        }
        
    }
    
    
    private class StopLocationFound:LocationFoundProtocol {
        
        var beaconInfo:SurveyBeaconInfo!
        var master:SurveyBeaconHandler!
        
        init(beaconInfo:SurveyBeaconInfo, master:SurveyBeaconHandler) {
            self.beaconInfo = beaconInfo
            self.master = master
        }
        
        func found(location:CLLocation) {
            self.master.checkTrip(self.beaconInfo, location:location)
        }
        
    }
    
}
