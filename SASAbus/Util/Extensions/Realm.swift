import Foundation
import RealmSwift
import Realm

extension Realm {

    public static func busStops() -> Realm {
        do {
            return try Realm(configuration: BusStopRealmHelper.CONFIG)
        } catch {
            fatalError("Failed to open bus stop realm: \(error)")
        }
    }
}
