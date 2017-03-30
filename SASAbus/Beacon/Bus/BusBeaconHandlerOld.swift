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
import SwiftyJSON
import RxCocoa
import RxSwift

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <<T:Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func ><T:Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class BusBeaconHandlerOld: BeaconHandlerProtocol {

    var beaconLocationHandlerStart: SurveyLocationHandler?
    var beaconLocationHandlerStop: SurveyLocationHandler?
    var beaconsToObserve = [String: SurveyBeaconInfo]()
    let surveyAction: SurveyActionProtocol

    let uuid = "e923b236-f2b7-4a83-bb74-cfb7fa44cab8"
    let identifier = "BUS"


    init(surveyAction: SurveyActionProtocol) {
        self.surveyAction = surveyAction
    }

    func beaconsInRange(_ beacons: [CLBeacon]) {
        for beacon in beacons {
            self.beaconInRange(Int(beacon.major), minor: Int(beacon.minor))
        }
    }

    func beaconInRange(_ major: Int, minor: Int) {
        let key: String = "\(self.uuid)_\(major)"

        if self.checkLastSurveyTime() == true {

            if beaconsToObserve.keys.contains(key) {
                let beaconInfo = beaconsToObserve[key] as SurveyBeaconInfo?
                beaconInfo!.seen()
                Log.info("Beacon has been seen for \((beaconInfo?.seconds.description)!)")
            } else {
                let beaconInfo = SurveyBeaconInfo(uuid: self.uuid, major: major, minor: minor, time: Int((Date()).timeIntervalSince1970))
                beaconsToObserve[key] = beaconInfo

                _ = RealtimeApi.vehicle(vehicle: major)
                        .subscribeOn(MainScheduler.asyncInstance)
                        .observeOn(MainScheduler.instance)
                        .subscribe(onNext: { bus in
                            if bus != nil {
                                beaconInfo.setBusInformation(bus!)
                            } else {
                                //get location from device
                                self.beaconLocationHandlerStart = SurveyLocationHandler(locationFoundProtocol: StartLocationFound(beaconInfo: beaconInfo))
                                self.beaconLocationHandlerStart!.getLocationAsync()
                            }
                        }, onError: { error in
                            Log.error(error)

                            //get location from device
                            self.beaconLocationHandlerStart = SurveyLocationHandler(locationFoundProtocol: StartLocationFound(beaconInfo: beaconInfo))
                            self.beaconLocationHandlerStart!.getLocationAsync()
                        })
            }
        }
    }

    func clearBeacons() {
        self.beaconsToObserve.removeAll()
    }

    func inspectBeacons() {
        let inspectBeaconGroup: DispatchGroup = DispatchGroup()

        for beacon in beaconsToObserve.values {
            inspectBeaconGroup.enter()
            checkIfBeaconIsSuitableForSurvey(beacon, group: inspectBeaconGroup)
        }

        inspectBeaconGroup.notify(queue: DispatchQueue.main, execute: {
            self.clearBeacons()
        })
    }

    func handlerIsActive() -> Bool {
        return true
    }

    func checkIfBeaconIsSuitableForSurvey(_ beaconInfo: SurveyBeaconInfo, group: DispatchGroup) {
        let now = Date()

        if (Int(beaconInfo.lastSeen.timeIntervalSince1970) + Config.beaconLastSeenThreshold) > Int(now.timeIntervalSince1970) {

            _ = RealtimeApi.vehicle(vehicle: beaconInfo.major)
                    .subscribeOn(MainScheduler.asyncInstance)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { bus in
                        if bus != nil {
                            beaconInfo.stopPositionItem = bus!
                            self.checkTrip(beaconInfo, location: bus!.getCoordinates())
                        } else {
                            self.beaconLocationHandlerStop =
                                    SurveyLocationHandler(locationFoundProtocol: StopLocationFound(beaconInfo: beaconInfo, master: self))
                            self.beaconLocationHandlerStop!.getLocationAsync()
                        }
                    }, onError: { error in
                        Log.error(error)

                        self.beaconLocationHandlerStop =
                                SurveyLocationHandler(locationFoundProtocol: StopLocationFound(beaconInfo: beaconInfo, master: self))
                        self.beaconLocationHandlerStop!.getLocationAsync()
                    })
        }
    }

    func getUuid() -> String {
        return uuid
    }

    func getIdentifier() -> String {
        return identifier
    }


    fileprivate func checkTrip(_ beaconInfo: SurveyBeaconInfo, location: CLLocation) {
        if beaconInfo.location != nil {
            let distance = beaconInfo.location!.distance(from: location)

            if Int(distance) > Config.beaconMinTripDistance &&
                       beaconInfo.seconds > Config.beaconSecondsInBus {

                Log.warning("trigger survey for " + beaconInfo.major.description)
                self.surveyAction.triggerSurvey(beaconInfo)
            }

        }
    }

    fileprivate func checkLastSurveyTime() -> Bool {
        var result: Bool = true
        let lastSurveyTimeStamp = UserDefaultHelper.instance.getLastSurveyTimeStamp()
        if lastSurveyTimeStamp != nil {

            let lastSurveyDate = Date(timeIntervalSince1970: TimeInterval(lastSurveyTimeStamp!))
            let secondsLastSurvey = Int(lastSurveyDate.timeIntervalSince1970)
            let secondsNow = Int(Date().timeIntervalSince1970)
            let secondsBetweenSurvey = secondsNow - secondsLastSurvey
            let prefSurveyRecurring = UserDefaultHelper.instance.getSurveyCycle()
            result = secondsBetweenSurvey > prefSurveyRecurring
        }
        return result
    }


    fileprivate class StartLocationFound: LocationFoundProtocol {

        var beaconInfo: SurveyBeaconInfo!

        init(beaconInfo: SurveyBeaconInfo) {
            self.beaconInfo = beaconInfo
        }

        func found(_ location: CLLocation) {
            self.beaconInfo.location = location
        }

    }

    fileprivate class StopLocationFound: LocationFoundProtocol {

        var beaconInfo: SurveyBeaconInfo!
        var master: BusBeaconHandlerOld!

        init(beaconInfo: SurveyBeaconInfo, master: BusBeaconHandlerOld) {
            self.beaconInfo = beaconInfo
            self.master = master
        }

        func found(_ location: CLLocation) {
            self.master.checkTrip(self.beaconInfo, location: location)
        }
    }
}
