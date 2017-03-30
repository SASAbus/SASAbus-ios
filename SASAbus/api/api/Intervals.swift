import Foundation
import SwiftyJSON

class Intervals {

    static var INTERVALS = [Interval: Int]()

    static func loadIntervals(baseDir: URL) {
        let jIntervals: JSON = IOUtils.readFileAsJson(path: baseDir.appendingPathComponent("SEL_FZT_FELD.json"))!

        // iterates through all the intervals
        for item in jIntervals.arrayValue {
            INTERVALS[Interval(
                fgr: item["FGR_NR"].intValue,
                busStop1: item["ORT_NR"].intValue,
                busStop2: item["SEL_ZIEL"].intValue
            )] = item["SEL_FZT"].intValue
        }

        Log.info("Loaded intervals")
    }

    static func getInterval(fgr: Int, busStop1: Int, busStop2: Int) -> Int {
        return INTERVALS[Interval(fgr: fgr, busStop1: busStop1, busStop2: busStop2)]!
    }
}
