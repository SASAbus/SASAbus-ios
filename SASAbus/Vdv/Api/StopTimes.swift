import Foundation
import SwiftyJSON

class StopTimes {

    static var STOP_TIMES = [StopTime: Int]()

    static func loadStopTimes(baseDir: URL) {
        let jStopTimes: JSON = IOUtils.readFileAsJson(path: baseDir.appendingPathComponent("ORT_HZT.json"))!

        // iterates through all the stop times
        for item in jStopTimes.arrayValue {
            STOP_TIMES[StopTime(id: item["FGR_NR"].intValue, stop: item["ORT_NR"].intValue)] = item["HP_HZT"].intValue
        }

        Log.info("Loaded stop times")
    }

    static func getStopSeconds(fgr: Int, stop: Int) -> Int {
        let stopTime = STOP_TIMES[StopTime(id: fgr, stop: stop)]
        return stopTime == nil ? 0 : stopTime!
    }
}
