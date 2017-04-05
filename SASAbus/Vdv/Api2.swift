//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//


/**
 * This is the main offline API where the app gets data from. This API tells us specific information
 * about departures and trips. It uses the SASA SpA-AG offline stored open data.

 * @author David Dejori
 */

import Foundation

class Api2 {

    static func getTrip(tripId: Int, verifyUiThread: Bool = true) -> VdvTrip {
        VdvHandler.blockTillLoaded(verifyUiThread: verifyUiThread)

        let trips: [VdvTrip] = VdvTrips.ofSelectedDay()

        for trip in trips {
            if trip.tripId == tripId {
                return trip
            }
        }

        Log.error("Trip \(tripId) not found")

        return VdvTrip.empty
    }

    static func getPassingLines(group: Int) -> [Int] {
        VdvHandler.blockTillLoaded()

        let busStops = BusStopRealmHelper.getBusStopsFromFamily(family: group)

        var lines = [Int]()
        for (key, value) in VdvPaths.getPaths() {
            for variant in value {
                if !Set(variant).isDisjoint(with: busStops) {
                    lines.append(key)
                    break
                }
            }
        }

        lines = lines.sorted { (lhs: Int, rhs: Int) -> Bool in
            return Lines.ORDER.index(of: lhs)! < Lines.ORDER.index(of: rhs)!
        }

        return lines
    }

    static func todayExists() -> Bool {
        VdvHandler.blockTillLoaded()

        var exists: Bool

        exists = VdvHandler.isValid

        do {
            try _ = VdvCalendar.today()
        } catch {
            Log.error("todayExists() error=\(error)")
            exists = false
        }

        if !exists {
            Log.error("Plan data not valid")
            // TODO
            // PlannedData.setUpdateAvailable(true)
        }

        return exists
    }
}

class ApiTime {

    static func addOffset(seconds: Int64) -> Int64 {
        // return seconds + DateTimeZone.forID("Europe/Rome").getOffset(seconds).toLong()
        return seconds + Int64(NSTimeZone(name: "Europe/Rome")!.daylightSavingTimeOffset)
    }

    static func now() -> Int64 {
        let now = Date().millis()
        return now + Int64(NSTimeZone(name: "Europe/Rome")!.daylightSavingTimeOffset)
    }

    static func toTime(seconds: Int) -> String {
        return String(format: "%02d:%02d", seconds / 3600 % 24, seconds % 3600 / 60)
    }
}
