import Foundation
import RealmSwift
import Realm
import RxSwift
import RxCocoa

class UserRealmHelper {

    static let DB_VERSION: Int = 1
    static let DB_NAME: String = "default.realm"

    static func setup() {
        var config = Realm.Configuration()

        config.schemaVersion = 3
        config.deleteRealmIfMigrationNeeded = true
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent(DB_NAME)

        config.objectTypes = [
            FavoriteLine.self,
            FavoriteBusStop.self,
            Trip.self,
            EarnedBadge.self,
            DisabledDeparture.self
        ]

        Realm.Configuration.defaultConfiguration = config
    }


    // ====================================== FAVORITES ============================================

    static func addFavoriteLine(lineId: Int) {
        let realm = try! Realm()

        if hasFavoriteLine(lineId: lineId) {
            // Line already exists in database, skip it.
            Log.debug("Favorite line \(lineId) already exists, skipping.")
            return
        }

        let favoriteLine = FavoriteLine()
        favoriteLine.id = lineId

        try! realm.write {
            realm.add(favoriteLine)
        }

        Log.debug("Added favorite line \(lineId)")
    }

    static func addFavoriteBusStop(busStopGroup: Int) {
        let realm = try! Realm()

        if hasFavoriteBusStop(busStopGroup: busStopGroup) {
            // Bus stop group already exists in database, skip it.
            Log.debug("Favorite bus stop group \(busStopGroup) already exists, skipping.")
            return
        }

        let favoriteBusStop = FavoriteBusStop()
        favoriteBusStop.group = busStopGroup

        try! realm.write {
            realm.add(favoriteBusStop)
        }

        Log.debug("Added favorite bus stop group \(busStopGroup)")
    }

    static func removeFavoriteLine(lineId: Int) {
        let realm = try! Realm()

        let line = realm.objects(FavoriteLine.self).filter("id = \(lineId)").first
        if line != nil {
            try! realm.write {
                realm.delete(line!)
            }
        }

        Log.debug("Removed favorite line \(lineId)")
    }

    static func removeFavoriteBusStop(busStopGroup: Int) {
        let realm = try! Realm()

        let busStop = realm.objects(FavoriteBusStop.self).filter("group = \(busStopGroup)").first
        if busStop != nil {
            try! realm.write {
                realm.delete(busStop!)
            }
        }

        Log.debug("Removed favorite bus stop group \(busStopGroup)")
    }

    static func hasFavoriteLine(lineId: Int) -> Bool {
        let realm = try! Realm()
        return realm.objects(FavoriteLine.self).filter("id = \(lineId)").count > 0
    }

    static func hasFavoriteBusStop(busStopGroup: Int) -> Bool {
        let realm = try! Realm()
        return realm.objects(FavoriteBusStop.self).filter("group = \(busStopGroup)").count > 0
    }


    // ======================================= TRIPS ===============================================

    static func insertTrip(beacon: BusBeacon) -> CloudTrip? {
        // Save the beacon trip list to a temporary list.
        var stops: [Int] = Array(beacon.busStops)
        beacon.busStops.removeAll()

        let startIndex = stops.index(of: beacon.origin) ?? -1

        if startIndex == -1 || startIndex + 1 > stops.count {
            Log.error("Trip \(beacon.id) startIndex invalid")
            return nil
        }

        // Get the stops from the didEnterRegion index till the end of the list.
        stops = Array(stops[(startIndex + 1)..<stops.count])

        let stopIndex = stops.index(of: beacon.destination) ?? -1

        // Check if the end index is bigger than 0, thus it exists in the list.
        if stopIndex == -1 {
            Log.error("Trip \(beacon.id) stopIndex == -1, destination=\(beacon.destination), stops=\(stops)")
            return nil
        }

        // Get the stops from the didEnterRegion index till the end index.
        let endIndex = stopIndex + 1 > stops.count ? stops.count : stopIndex + 1
        var stopList: [Int] = Array(stops[0..<endIndex])

        if stopList.isEmpty {
            Log.error("Trip \(beacon.id) invalid, stopList.isEmpty: stops=\(stops), origin=\(beacon.origin), " +
                    "destination=\(beacon.destination)")

            return nil
        }

        stopList.insert(beacon.origin, at: 0)

        var sb = ""

        for i in stopList {
            sb += "\(i), "
        }

        sb = String(sb.characters.dropLast(2))

        let realm = try! Realm()

        let trip = Trip()
        trip.vehicle = beacon.id
        trip.tripHash = beacon.tripHash

        trip.lines = beacon.lines.flatMap {
            String($0)
        }.joined(separator: Config.DELIMITER)

        trip.variants = beacon.variants.flatMap {
            String($0)
        }.joined(separator: Config.DELIMITER)

        trip.trips = beacon.trips.flatMap {
            String($0)
        }.joined(separator: Config.DELIMITER)

        trip.origin = beacon.origin
        trip.destination = beacon.destination
        trip.departure = beacon.startDate.millis() / 1000
        trip.arrival = beacon.lastSeen / 1000
        trip.path = sb
        trip.fuelPrice = Config.DIESEL_PRICE

        try! realm.write {
            realm.add(trip)
        }

        Log.warning("Inserted trip \(beacon.tripHash)")

        let cloudTrip = CloudTrip(trip: trip)

        // Only post the trip if the user is logged in, as trip uploads are restricted to
        // eco point users only.
        if AuthHelper.isLoggedIn() {
            TripSyncHelper.upload(trips: [cloudTrip], scheduler: MainScheduler.background)
        } else {
            Log.info("Skipping trip upload, user not logged in")
        }

        return cloudTrip
    }


    // ======================================= BADGES ==============================================

    static func hasEarnedBadge(badgeId: Int) -> Bool {
        let realm = try! Realm()

        let badge = realm.objects(EarnedBadge.self).filter("id == \(badgeId)").first

        return badge != nil
    }

    static func setEarnedBadge(badgeId: Int) {
        let realm = try! Realm()

        let badge = EarnedBadge()
        badge.id = badgeId

        try! realm.write {
            realm.add(badge)
        }
    }


    // ======================================= DEPARTURE FILTER ==============================================

    static func setDisabledDepartures(lines: [Int]) {
        let realm = try! Realm()

        try! realm.write {
            let objects = realm.objects(DisabledDeparture.self)
            realm.delete(objects)
        }

        try! realm.write {
            for line in lines {
                let filter = DisabledDeparture()
                filter.line = line

                realm.add(filter)
            }
        }
    }

    static func getDisabledDepartures() -> [Int] {
        let realm = try! Realm()

        let filtered = realm.objects(DisabledDeparture.self)
        var lines: [Int] = []

        for filter in filtered {
            lines.append(filter.line)
        }

        return lines
    }
}
