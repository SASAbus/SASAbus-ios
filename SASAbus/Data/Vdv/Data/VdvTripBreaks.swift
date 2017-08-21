//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 * Describes the stop times at a bus stop for some specific trips. Those trips are identifiable by
 * their unique ID being 'FRT_FID' in the SASA SpA-AG open data.
 *
 * @author David Dejori
 */

class VdvTripBreaks {

    static var STOP_TIMES = [VdvStopTime: Int]()

    /**
     * Loads the pre-planned stop times at some bus stops in some pre-defined trips.
     *
     * @param jHaltTimes the JSON data with the corresponding information
     */
    static func loadBreaks(jHaltTimes: [JSON]) {
        var map = [VdvStopTime: Int]()

        for i in 0...jHaltTimes.count - 1 {
            var jStopTime = jHaltTimes[i]

            let stopTime = VdvStopTime(
                    id: jStopTime["trip_id"].intValue,
                    stop: jStopTime["bus_stop_id"].intValue
            )

            map[stopTime] = jStopTime["stop_time"].intValue
        }

        STOP_TIMES = map
    }

    /**
     * Retrieves how long a bus is stopping at a specific bus stop in its path. When a bus just
     * passes a bus stop (which applies to the most cases), stops and departs again (in order to let
     * the passengers get onto and off the bus), that is not referred as a break and thus the method
     * will return 0 for nearly all stops. Only if there is a pre-planned break (most likely of some
     * minutes) the method will return the seconds a bus stops at that bus stop.
     *
     * @param tripId  the ID of a trip
     * @param busStop the bus stop in the trip
     * @return the amount of seconds the bus of the given trip waits at the given stop
     */
    public static func getStopTime(tripId: Int, busStop: Int) -> Int {
        let stopTime = STOP_TIMES[VdvStopTime(id: tripId, stop: busStop)]
        return stopTime ?? 0
    }
}
