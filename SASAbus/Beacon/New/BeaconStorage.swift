import Foundation

class BeaconStorage {

    static let PREF_BEACON_CURRENT_TRIP = "pref_beacon_current_trip"
    static let PREF_BUS_BEACON_MAP = "pref_bus_beacon_map"
    static let PREF_BUS_BEACON_MAP_LAST = "pref_bus_beacon_map_last"

    static var currentTrip: CurrentTrip?

    static func setCurrentTrip(trip: CurrentTrip?) {
        currentTrip = trip

        if let trip = trip {
            if trip.checkUpdate() && trip.isNotificationShown &&
                (trip.beacon?.isSuitableForTrip)! && Settings.isBusNotificationEnabled() {

                //BusBeaconHandler.notificationAction.showNotification(trip);
            }

            let json = trip.toJsonString(prettyPrinted: true)
            UserDefaults.standard.set(json, forKey: PREF_BEACON_CURRENT_TRIP)
        } else {
            Log.info("trip == null, cancelling notification")

            //NotificationUtils.cancelBus(mContext);

            UserDefaults.standard.removeObject(forKey: PREF_BEACON_CURRENT_TRIP)
        }
    }

    static func getCurrentTrip() -> CurrentTrip? {
        if let currentTrip = currentTrip {
            return currentTrip
        }

        currentTrip = readCurrentTrip()
        return currentTrip
    }

    static func readCurrentTrip() -> CurrentTrip? {
        let json = UserDefaults.standard.object(forKey: PREF_BEACON_CURRENT_TRIP)

        if json == nil {
            return nil
        }

        let trip = CurrentTrip(json: json as! String)

        trip.update()

        if trip.beacon?.getLastTrip() == 0 {
            return nil
        }

        if trip.getPath().isEmpty || trip.getTimes()?.isEmpty == false {
            Log.info("path or times empty for current trip")

            trip.reset()
        }

        return trip
    }

    static func writeBeaconMap(map: [Int:BusBeacon]?) {
        if map == nil {
            UserDefaults.standard.removeObject(forKey: PREF_BUS_BEACON_MAP_LAST)
        } else {
            var dictionary = [Int: String]()

            for (key, beacon) in map! {
                dictionary[key] = beacon.toJsonString()
            }

            UserDefaults.standard.set(dictionary, forKey: PREF_BUS_BEACON_MAP)
            UserDefaults.standard.set(Int(Date().millis()), forKey: PREF_BUS_BEACON_MAP_LAST)
        }
    }

    static func getBeaconMap() -> [Int:BusBeacon] {
        var currentTripTimeStamp = 0

        let timeStamp = UserDefaults.standard.integer(forKey: PREF_BUS_BEACON_MAP_LAST)
        if timeStamp != -999 {
            currentTripTimeStamp = timeStamp
        }

        if currentTripTimeStamp != 0 {
            let nowTimeStamp = Date().millis()
            let difference = nowTimeStamp - currentTripTimeStamp
            let configuredMilliseconds = 240000

            if Int64(difference) < Int64(configuredMilliseconds) {
                let map = UserDefaults.standard.dictionary(forKey: PREF_BUS_BEACON_MAP)
                if map == nil {
                    return [:]
                }

                var realMap = [Int: BusBeacon]()

                for (key, value) in map! {
                    realMap[Int(key)!] = BusBeacon(json: value as! String)
                }

                return realMap
            } else {
                setCurrentTrip(trip: nil)
                return [:]
            }
        }

        return [:]
    }

    static func hasCurrentTrip() -> Bool {
        return getCurrentTrip() != nil
    }
}
