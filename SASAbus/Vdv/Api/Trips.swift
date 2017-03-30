import Foundation
import SwiftyJSON

class Trips {

    static var TRIPS = [Trip]()

    static func loadTrips(baseDir: URL) {
        if !API.todayExists() {
            return
        }

        var millis = Date().timeIntervalSince1970 * 1000

        if Int(millis / 1000) % 86400 < 5400 {
            millis -= 86400000
        }

        let today = CompanyCalendar.getDayType(date: API.DATE.string(from: Date(timeIntervalSince1970: millis / 1000)))

        let jDepartures: JSON = IOUtils.readFileAsJson(path: baseDir.appendingPathComponent("REC_FRT.json"))!

        for jLine in jDepartures.arrayValue {
            for jDay in jLine["tagesartlist"].arrayValue {
                if jDay["TAGESART_NR"].intValue == today {
                    for jVariant in jDay["varlist"].arrayValue {
                        for jDeparture in jVariant["triplist"].arrayValue {
                            TRIPS.append(Trip(
                                line: jLine["LI_NR"].intValue,
                                variant: jVariant["STR_LI_VAR"].intValue,
                                day: today,
                                time: jDeparture["FRT_START"].intValue,
                                fgr: jDeparture["FGR_NR"].intValue,
                                trip: jDeparture["FRT_FID"].intValue
                            ))
                        }
                    }
                }
            }
        }

        Log.info("Loaded trips")
    }

    static func getTrip(id: Int) -> Trip? {
        for trip in TRIPS {
            if trip.getTrip() == id {
                return trip
            }
        }

        return nil
    }

    static func getPath(tripId: Int) -> [ApiBusStop]? {
        Handler.load()

        for trip in TRIPS {
            if trip.getTrip() == tripId {
                return trip.getPath()
            }
        }

        return nil
    }

    static func getTrips(day: Int, line: Int) -> [Trip] {
        var trips = [Trip]()

        for trip in TRIPS {
            if trip.getLine() == line && trip.getDay() == day {
                trips.append(trip)
            }
        }

        return trips
    }

    static func getTrips(day: Int, line: Int, variant: Int) -> [Trip] {
        var trips = [Trip]()

        for trip in TRIPS {
            if trip.getLine() == line && trip.getVariant() == variant && trip.getDay() == day {
                trips.append(trip)
            }
        }

        return trips
    }

    static func getCoursesPassingAt(station: ApiBusStop) -> [[Int]] {
        var coursesPassingAtStation = [[Int]]()

        for (key, listMap) in Paths.getPaths() {
            for (key2, list) in listMap {
                if list.contains(station) && list.index(of: station) != list.count - 1 {
                    coursesPassingAtStation.append([
                        key, key2
                    ])
                }
            }
        }

        return coursesPassingAtStation
    }
}
