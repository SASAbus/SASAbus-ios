import Foundation
import SwiftyJSON

/**
 * Retrieves travel times between two bus stops (depending from driving speed severity as described
 * by 'FGR_NR'). Travel times are stored in seconds but are always full minutes, e. g. 0, 60, 120...
 */
class VdvTravelTimes {

    static var INTERVALS = [VdvInterval: Int]()

    /**
     * Loads the travel times between two bus stops. The times are given in seconds. They may defer
     * for the same two bus stops at a different time as there are on-peak and off-peak schedules.
     *
     * @param jIntervals the JSON data with the corresponding information
     */
    static func loadTravelTimes(jIntervals: [JSON]) {
        var map = [VdvInterval: Int]()

        for i in 0...jIntervals.count - 1 {
            var jInterval = jIntervals[i]

            let interval = VdvInterval(
                    timeGroup: jInterval["tg"].intValue,
                    origin: jInterval["oi"].intValue,
                    destination: jInterval["di"].intValue
            )

            map[interval] = jInterval["tt"].intValue
        }

        INTERVALS = map
    }

    static func getInterval(timeGroup: Int, origin: Int, destination: Int) -> Int {
        let interval = VdvInterval(timeGroup: timeGroup, origin: origin, destination: destination)
        return INTERVALS[interval] ?? 0
    }
}
