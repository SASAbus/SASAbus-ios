import Foundation
import SwiftyJSON

class CompanyCalendar {

    static var CALENDAR = [String: Int]()

    static func loadCalendar(baseDir: URL) {
        let calendar: JSON = IOUtils.readFileAsJson(path: baseDir.appendingPathComponent("FIRMENKALENDER.json"))!

        for item in calendar.arrayValue {
            CALENDAR[item["BETRIEBSTAG"].stringValue] = item["TAGESART_NR"].intValue
        }

        Log.info("Loaded company calendar")
    }

    static func getDayType(date: String) -> Int {
        let day = CALENDAR[date]
        return day == nil ? -1 : day!
    }
}
