import Foundation

import Realm
import RealmSwift

import Crashlytics

class Utils {

    static func locale() -> String {
        let fullLocale: String = Locale.preferredLanguages.first! as String
        return String(fullLocale.characters.prefix(2))
    }
    
    static func localeDeIt() -> String {
        let fullLocale: String = Locale.preferredLanguages.first! as String
        let shortLocale = String(fullLocale.characters.prefix(2))
        
        return shortLocale == "de" ? "de" : "it"
    }

    static func insertTripIfValid(beacon: BusBeacon) -> CloudTrip? {
        if beacon.origin == beacon.destination && beacon.lastSeen - beacon.startDate.millis() < 600000 {
            Log.error("Trip \(beacon.id) invalid -> origin == destination => \(beacon.origin) == \(beacon.destination)")
            return nil
        }

        let realm = try! Realm()
        let trip = realm.objects(Trip.self).filter("tripHash == '\(beacon.tripHash)'").first

        if trip != nil {
            // Trip is already in db.
            // We do not care about this error so do not show an error notification
            return nil
        }

        return UserRealmHelper.insertTrip(beacon: beacon)
    }

    static func roundToPlaces(_ value: Double, places: Int) -> Double {
        let factor = pow(10.0, places).doubleValue
        return round(value * factor) / factor
    }
    
    static func logError(_ error: Error, message: String? = nil) {
        if let message = message {
            Log.error("ERROR: message='\(message)', error='\(error.localizedDescription)'")
        } else {
            Log.error("ERROR: error='\(error.localizedDescription)'")
        }

        #if RELEASE
            if let message = message {
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["message": message])
            } else {
                Crashlytics.sharedInstance().recordError(error)
            }
        #endif
    }
}

extension Decimal {

    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}

extension Bundle {

    var versionName: String {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unavailable"
    }

    var versionCode: String {
        return self.infoDictionary?["CFBundleVersion"] as? String ?? "Unavailable"
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
