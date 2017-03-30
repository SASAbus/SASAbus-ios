import Foundation
import SwiftyJSON

class HaltTimes {

    static var HALT_TIMES = [StopTime: Int]()

    static func loadHaltTimes(baseDir: URL) {
        let jHaltTimes: JSON = IOUtils.readFileAsJson(path: baseDir.appendingPathComponent("REC_FRT_HZT.json"))!

        // iterates through all the stop times
        for item in jHaltTimes.arrayValue {
            HALT_TIMES[StopTime(
                id: item["FRT_FID"].intValue,
                stop: item["ORT_NR"].intValue
            )] = item["FRT_HZT_ZEIT"].intValue
        }

        Log.info("Loaded halt times")
    }

    static func getStopSeconds(trip: Int, stop: Int) -> Int {
        let stopTime = HALT_TIMES[StopTime(id: trip, stop: stop)]
        return stopTime == nil ? 0 : stopTime!
    }
}
