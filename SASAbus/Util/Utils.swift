import Foundation
import Realm
import RealmSwift

class Utils {

    static func locale() -> String {
        let fullLocale: String = Locale.preferredLanguages.first! as String
        return String(fullLocale.characters.prefix(2))
    }

    static func insertTripIfValid(beacon: BusBeacon) -> Bool {
        if beacon.origin == beacon.destination && beacon.lastSeen - beacon.startDate.millis() < 600000 {
            Log.error("Trip \(beacon.id) invalid -> origin == destination => \(beacon.origin) == \(beacon.destination)")
            return false
        }

        let realm = try! Realm()
        let trip = realm.objects(Trip.self).filter("tripHash == '\(beacon.tripHash)'").first

        if trip != nil {
            // Trip is already in db.
            // We do not care about this error so do not show an error notification
            return false
        }

        return UserRealmHelper.insertTrip(beacon: beacon)
    }

    static func roundToPlaces(_ value: Double, places: Int) -> Double {
        let factor = pow(10.0, places).doubleValue
        return round(value * factor) / factor
    }
}

extension Decimal {

    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}
