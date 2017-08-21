import Foundation
import SwiftyJSON

class VdvTrips {

    static var jDepartures: [JSON]!
    static var TRIPS = [VdvTrip]()

    public static func loadTrips(jDepartures: [JSON]?, dayId: Int) {
        Log.warning("Loading trips of day \(dayId)")

        if jDepartures != nil {
            VdvTrips.jDepartures = jDepartures!
        }

        var trips = [VdvTrip]()

        for i in 0...VdvTrips.jDepartures.count - 1 {
            var jLine = VdvTrips.jDepartures[i]

            for j in 0...jLine["days"].count - 1 {
                var jDay = jLine["days"][j]

                if jDay["day_id"].intValue == dayId {
                    for k in 0...jDay["variants"].count - 1 {
                        var jVariant = jDay["variants"][k]

                        for l in 0...jVariant["trips"].count - 1 {
                            var jDeparture = jVariant["trips"][l]

                            trips.append(VdvTrip(
                                    lineId: jLine["line_id"].intValue,
                                    variant: jVariant["variant_id"].intValue,
                                    departure: jDeparture["departure"].intValue,
                                    timeGroup: jDeparture["time_group"].intValue,
                                    tripId: jDeparture["trip_id"].intValue
                            ))
                        }
                    }
                }
            }
        }

        TRIPS = trips
    }

    static func ofSelectedDay() -> [VdvTrip] {
        return TRIPS
    }
}
