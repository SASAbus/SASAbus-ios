//
//  TripUtils.swift
//  SASAbus
//
//  Created by Alex Lardschneider on 27/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class TripUtils {
    
    static func insertTripIfValid(beacon: BusBeacon) -> CloudTrip? {
        if beacon.origin == beacon.destination && beacon.lastSeen - beacon.startDate.millis() < 600000 {
            Log.error("Trip \(beacon.id) invalid -> origin == destination => \(beacon.origin) == \(beacon.destination)")
            return nil
        }
        
        let realm = try! Realm()
        let trip = realm.objects(Trip.self).filter("tripHash == '\(beacon.tripHash)'").first
        
        if trip != nil {
            // Trip is already in db.
            // We do not care about this error so do not show an error notification
            return nil
        }
        
        return UserRealmHelper.insertTrip(beacon: beacon)
    }
}
