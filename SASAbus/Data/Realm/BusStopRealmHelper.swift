import Foundation

import RealmSwift
import Realm

func bundleURL(name: String) -> URL? {
    return Bundle.main.url(forResource: name, withExtension: "realm")
}

class BusStopRealmHelper {

    static var CONFIG: Realm.Configuration!

    static let locale = Utils.locale()

    static func setup() {
        let url = bundleURL(name: "busstops")

        CONFIG = Realm.Configuration()
        CONFIG.fileURL = url
        CONFIG.objectTypes = [BusStop.self]
        CONFIG.readOnly = true
        CONFIG.schemaVersion = 1

        do {
            _ = try Realm(configuration: CONFIG)
        } catch {
            fatalError("Could not open bus stop realm: \(error)")
        }
    }


    static func getName(id: Int, realm: Realm = Realm.busStops()) -> String {
        let busStop = realm.objects(BusStop.self).filter("id = \(id)").first

        if busStop == nil {
            return "Unknown"
        }

        return (locale == "de" ? busStop!.nameDe : busStop!.nameIt)!
    }

    static func getMunic(id: Int, realm: Realm = Realm.busStops()) -> String {
        let busStop = realm.objects(BusStop.self).filter("id = \(id)").first

        if busStop == nil {
            return "Unknown"
        }

        return (locale == "de" ? busStop!.municDe : busStop!.municIt)!
    }

    static func getBusStop(id: Int, realm: Realm = Realm.busStops()) -> BusStop {
        var busStop = realm.objects(BusStop.self).filter("id = \(id)").first

        if busStop == nil {
            busStop = BusStop(id: id, name: String(id), munic: String(id), lat: 0, lng: 0, family: 0)
        }

        return busStop!
    }

    static func getBusStopOrNil(id: Int) -> BusStop? {
        let realm = Realm.busStops()
        return realm.objects(BusStop.self).filter("id = \(id)").first
    }

    static func getBusStopGroup(id: Int) -> Int {
        let realm = Realm.busStops()
        var busStop = realm.objects(BusStop.self).filter("id = \(id)").first

        if busStop == nil {
            busStop = BusStop(id: id, name: String(id), munic: String(id), lat: 0, lng: 0, family: 0)
        }

        return (busStop?.family)!
    }

    static func getBusStopsFromFamily(family: Int) -> [VdvBusStop] {
        let realm = Realm.busStops()

        let busStops = realm.objects(BusStop.self).filter("family = \(family)")

        if busStops.isEmpty {
            Log.error("Invalid family id: \(family)")
            return []
        }

        var stops = [VdvBusStop]()

        for busStop in busStops {
            stops.append(VdvBusStop(id: busStop.id))
        }

        return stops
    }

    static func getBusStopsFromGroup(group: Int) -> [BusStop] {
        let realm = Realm.busStops()
        let results = realm.objects(BusStop.self).filter("family = \(group)")

        return Array(results)
    }


    static func all() -> [BusStop] {
        let realm = Realm.busStops()
        let results = realm.objects(BusStop.self)

        return Array(results)
    }
}
