import Foundation
import SwiftyJSON

class VdvTrips {

    private static var todayDayId: Int?
    private static var otherDayId: Int?
    
    private static var TRIPS_TODAY = [VdvTrip]()
    private static var TRIPS_OTHER_DAY = [VdvTrip]()


    public static func loadTrips(day: Int, isToday: Bool = false) throws {
        if let todayDayId = todayDayId, todayDayId == day && isToday {
            Log.warning("Trips for today already loaded, skipping...")
            return
        }
        
        if let otherDayId = otherDayId, otherDayId == day && !isToday {
            Log.warning("Trips for day \(day) already loaded, skipping...")
            return
        }
        
        var json = try IOUtils.readFileAsJson(path: VdvHandler.getTripsDataFile(day: day))

        Log.warning("Loading trips of day \(day)")

        var trips = [VdvTrip]()

        for i in 0...json.count - 1 {
            var line = json[i]

            for k in 0...line["variants"].count - 1 {
                var variant = line["variants"][k]

                for l in 0...variant["trips"].count - 1 {
                    var it = variant["trips"][l]

                    trips.append(VdvTrip(
                            lineId: line["line"].intValue,
                            variant: variant["variant"].intValue,
                            departure: it["d"].intValue,
                            timeGroup: it["tg"].intValue,
                            tripId: it["t"].intValue
                    ))
                }
            }
        }

        if isToday {
            todayDayId = day
            TRIPS_TODAY.append(contentsOf: trips)
        } else {
            otherDayId = day
            TRIPS_OTHER_DAY.removeAll()
            TRIPS_OTHER_DAY.append(contentsOf: trips)
        }
    }

    public static func loadTripsOfToday() throws {
        let today = try VdvCalendar.today()
        try loadTrips(day: today.id, isToday: true)
    }


    static func ofSelectedDay() -> [VdvTrip] {
        return TRIPS_TODAY
    }

    static func ofOtherDay() -> [VdvTrip] {
        return TRIPS_OTHER_DAY
    }
}
