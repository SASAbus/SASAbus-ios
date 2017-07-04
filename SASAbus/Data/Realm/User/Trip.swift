import Foundation
import RealmSwift
import Realm

class Trip: Object {

    dynamic var tripHash: String = ""
    dynamic var path: String?

    dynamic var lines: String?

    dynamic var variants: String?

    dynamic var trips: String?

    dynamic var vehicle: Int = 0

    dynamic var origin: Int = 0
    dynamic var destination: Int = 0

    dynamic var departure: Int64 = 0
    dynamic var arrival: Int64 = 0

    dynamic var fuelPrice: Float = 0

    func getTripsAsList() -> [Int] {
        return trips!.components(separatedBy: Config.DELIMITER).map {
            Int($0)!
        }
    }

    func getLinesAsList() -> [Int] {
        return lines!.components(separatedBy: Config.DELIMITER).map {
            Int($0)!
        }
    }

    func getVariantsAsList() -> [Int] {
        return variants!.components(separatedBy: Config.DELIMITER).map {
            Int($0)!
        }
    }
}
