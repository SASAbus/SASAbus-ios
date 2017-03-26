import Foundation

class Utils {

    static func locale() -> String {
        let fullLocale: String = Locale.preferredLanguages.first! as String
        return String(fullLocale.characters.prefix(2))
    }
    
    /*static func insertTripIfValid(beacon: BusBeacon) -> Bool {
        return true
    }*/
}
