import Foundation
import SwiftyJSON

/**
 * Retrieves travel times between two bus stops (depending from driving speed severity as described
 * by 'FGR_NR'). Travel times are stored in seconds but are always full minutes, e. g. 0, 60, 120...
 */

class VdvIntervals {

    static var INTERVALS = [VdvInterval: Int]()

    /**
     * Loads the travel times between two bus stops. The times are given in seconds. They may defer
     * for the same two bus stops at a different time as there are on-peak and off-peak schedules.
     *
     * @param jIntervals the JSON data with the corresponding information
     */
    static func loadIntervals(jIntervals: [JSON]) {
        var map = [VdvInterval: Int]()

        for i in 0...jIntervals.count - 1 {
            var jInterval = jIntervals[i]

            var interval = VdvInterval(
                    timeGroup: jInterval["time_group"].intValue,
                    origin: jInterval["origin_id"].intValue,
                    destination: jInterval["destination_id"].intValue
            )

            map[interval] = jInterval["travel_time"].intValue
        }

        INTERVALS = map
    }

    static func getInterval(timeGroup: Int, origin: Int, destination: Int) -> Int {
        var interval = VdvInterval(timeGroup: timeGroup, origin: origin, destination: destination)
        return INTERVALS[interval] ?? 0
    }
}
