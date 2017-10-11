/**
 * This is the main offline API where the app gets data from. This API tells us specific information
 * about departures and trips. It uses the SASA SpA-AG offline stored open data.
 *
 * @author David Dejori
 */
import Foundation

class Api {

    static func getTrip(tripId: Int, verifyUiThread: Bool = true) -> VdvTrip {
        VdvHandler.blockTillLoaded(verifyUiThread: verifyUiThread)

        let trips: [VdvTrip] = VdvTrips.ofSelectedDay()

        for trip in trips {
            if trip.tripId == tripId {
                return trip
            }
        }

        Log.error("Trip \(tripId) not found")

        return VdvTrip.empty
    }

    static func getPassingLines(group: Int) -> [Int] {
        VdvHandler.blockTillLoaded()

        let busStops = BusStopRealmHelper.getBusStopsFromFamily(family: group)

        var lines = [Int]()
        for (key, value) in VdvPaths.getPaths() {
            for variant in value {
                if !Set(variant).isDisjoint(with: busStops) {
                    lines.append(key)
                    break
                }
            }
        }

        lines = lines.sorted { (lhs: Int, rhs: Int) -> Bool in
            let a = Lines.ORDER.index(of: lhs) ?? Lines.ORDER.count
            let b = Lines.ORDER.index(of: rhs) ?? Lines.ORDER.count

            return a < b
        }

        return lines
    }

    static func todayExists() -> Bool {
        VdvHandler.blockTillLoaded()

        var exists: Bool

        exists = VdvHandler.isValid

        do {
            try _ = VdvCalendar.today()
        } catch {
            Log.error("todayExists() error=\(error)")
            exists = false
        }

        if !exists {
            Log.error("Plan data not valid")
            PlannedData.setUpdateAvailable(true)
        }

        return exists
    }
}
