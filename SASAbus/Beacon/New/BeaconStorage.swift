import Foundation
import RealmSwift

class BeaconStorage {

    private static var mCurrentTrip: CurrentTrip?
    private static var mCurrentBusStop: BusStopBeacon?

    private static var PREF_BEACON_CURRENT_TRIP = "pref_beacon_current_trip"
    private static var PREF_BEACON_CURRENT_BUS_STOP = "pref_beacon_current_bus_stop"
    private static var PREF_BUS_BEACON_MAP = "pref_bus_beacon_map"
    private static var PREF_BUS_BEACON_MAP_LAST = "pref_bus_beacon_map_last"

    private static var BEACON_MAP_TIMEOUT: Int64 = 240 * 1000

    static func clear() {
        Log.error("Clearing beacon storage")

        UserDefaults.standard.removeObject(forKey: PREF_BEACON_CURRENT_TRIP)
        UserDefaults.standard.removeObject(forKey: PREF_BUS_BEACON_MAP)
        UserDefaults.standard.removeObject(forKey: PREF_BUS_BEACON_MAP_LAST)
    }


// =================================== CURRENT TRIP ============================================

    static func saveCurrentTrip(trip: CurrentTrip?) {
        mCurrentTrip = trip

        if trip == nil {
            Log.error("trip == null, cancelling notification")
            // TODO
            // TripNotification.hide(mContext, null)

            UserDefaults.standard.removeObject(forKey: PREF_BEACON_CURRENT_TRIP)
        } else {
            var json = trip!.toJSONString(prettyPrint: false)
            UserDefaults.standard.set(json, forKey: PREF_BEACON_CURRENT_TRIP)
        }
    }

    static var currentTrip: CurrentTrip? {
        get {
            if mCurrentTrip == nil {
                mCurrentTrip = readCurrentTrip()
            }

            return mCurrentTrip
        }
    }

    static private func readCurrentTrip() -> CurrentTrip? {
        var json = UserDefaults.standard.string(forKey: PREF_BEACON_CURRENT_TRIP)

        if json == nil {
            return nil
        }

        if let trip = CurrentTrip(JSONString: json!) {
            trip.update()

            if trip.beacon.lastTrip == 0 {
                return nil
            }

            if trip.path.isEmpty || trip.times != nil && trip.times!.isEmpty {
                Log.error("Path or times empty for current trip, will reset...")

                trip.reset()
            }

            return trip
        }

        return nil
    }

    static func hasCurrentTrip() -> Bool {
        return currentTrip != nil
    }


// ================================= CURRENT BUS STOP ==========================================

    static func saveCurrentBusStop(beacon: BusStopBeacon?) {
        mCurrentBusStop = beacon

        if beacon == nil {
            UserDefaults.standard.removeObject(forKey: PREF_BEACON_CURRENT_BUS_STOP)
        } else {
            var json = beacon!.toJSONString(prettyPrint: false)
            Log.trace("Saving current bus stop: \(json)")
            UserDefaults.standard.set(json, forKey: PREF_BEACON_CURRENT_TRIP)
        }
    }

    static var currentBusStop: BusStopBeacon? {
        get {
            if mCurrentBusStop == nil {
                mCurrentBusStop = readCurrentBusStop()
            }

            return mCurrentBusStop
        }
    }

    private static func readCurrentBusStop() -> BusStopBeacon? {
        var json = UserDefaults.standard.string(forKey: PREF_BEACON_CURRENT_BUS_STOP)

        if json == nil {
            return nil
        }

        Log.trace("Reading current bus stop: \(json)")

        if let beacon = BusStopBeacon(JSONString: json!) {
            beacon.busStop = BusStopRealmHelper.getBusStop(id: beacon.id)
            return beacon
        }

        return nil
    }


// ==================================== BEACON MAP =============================================

    static func writeBeaconMap(map: [Int : BusBeacon]?) {
        if map == nil {
            UserDefaults.standard.removeObject(forKey: PREF_BUS_BEACON_MAP_LAST)
        } else {
            /*let returnDict = NSMutableDictionary()

            for (key, value) in map! {
                returnDict[String(key)] = value.toJsonString()
            }*/

            UserDefaults.standard.set("", forKey: PREF_BUS_BEACON_MAP)
            UserDefaults.standard.set(Date().seconds(), forKey: PREF_BUS_BEACON_MAP_LAST)
        }
    }

    static var beaconMap: [Int : BusBeacon] {
        get {
            var lastMapSave: Int64 = 0

            if UserDefaults.standard.integer(forKey: PREF_BUS_BEACON_MAP_LAST) != 0 {
                lastMapSave = Int64(UserDefaults.standard.integer(forKey: PREF_BUS_BEACON_MAP_LAST) * 1000)
            }

            if lastMapSave != 0 {
                let difference = Date().millis() - lastMapSave

                if difference < BEACON_MAP_TIMEOUT {
                    do {
                        let json = UserDefaults.standard.string(forKey: PREF_BUS_BEACON_MAP)

                        if json == nil {
                            return [:]
                        }

                        /*var oldDict = NSMutableDictionary(json: json!) as! [String : String]
                        var newDict = [Int: BusBeacon]()

                        for (key, value) in oldDict {
                            newDict[Int(key)!] = BusBeacon(json: value)
                        }

                        return newDict*/

                        return [:]
                    } catch {
                        Log.error(error)
                    }

                } else {
                    saveCurrentTrip(trip: nil)
                }
            }

            return [:]
        }
    }
}
