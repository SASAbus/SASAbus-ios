import Foundation
import SwiftyJSON

class VdvBusStopBreaks {

    static var STOP_TIMES = [VdvStopTime: Int]()

    /**
     * Loads the breaks done in some specific trips at a defined stop.
     *
     * @param jStopTimes the JSON data with the corresponding information
     */
    static func loadBreaks(jStopTimes: [JSON]) {
        var map = [VdvStopTime: Int]()

        // iterates through all the stop times
        for i in 0...jStopTimes.count - 1 {
            var jStopTime = jStopTimes[i]

            let stopTime = VdvStopTime(
                    id: jStopTime["tg"].intValue,
                    stop: jStopTime["bs"].intValue
            )

            map[stopTime] = jStopTime["st"].intValue
        }

        STOP_TIMES = map
    }

    /**
     * Retrieves how long a bus is stopping at a specific bus stop in its path. If there is
     * pre-planned break (most likely of some minutes) the method will return the seconds a bus
     * stops at that bus stop.
     *
     * @param timeGroup the time group (peak times or not and so on)
     * @param busStop   the bus stop in the trip
     * @return the amount of seconds the bus of the given trip waits at the given stop
     */
    public static func getStopTime(timeGroup: Int, busStop: Int) -> Int {
        let stopTime = STOP_TIMES[VdvStopTime(id: timeGroup, stop: busStop)]
        return stopTime ?? 0
    }
}
