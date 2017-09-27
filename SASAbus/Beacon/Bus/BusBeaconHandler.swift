import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class BusBeaconHandler: NSObject {

    var MAX_BEACON_DISTANCE: Int64 = 5
    var BUS_LAST_SEEN_THRESHOLD: Int64 = 180000
    var SECONDS_IN_BUS: Int64 = 90
    var MIN_NOTIFICATION_SECONDS: Int64 = 60

    private var TIMEOUT: Int64 = 10000

    private var TIMER_INTERVAL: Double = 150 // Seconds

    private let UUID_STRING = "e923b236-f2b7-4a83-bb74-cfb7fa44cab8"
    private let IDENTIFIER = "BUS"

    let locationManager = CLLocationManager()
    var region: CLBeaconRegion!
    var regions: [String: CLBeaconRegion] = [:]

    private var mCycleCounter = 0

    private var beaconMap = [Int: BusBeacon]()

    static let instance = BusBeaconHandler()
    

    private override init() {
        super.init()
        
        self.locationManager.delegate = self

        self.region = CLBeaconRegion(proximityUUID: UUID(uuidString: UUID_STRING)!, identifier: IDENTIFIER)
        self.region.notifyEntryStateOnDisplay = true
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
    }


    func startObserving() {
        Log.warning("startObserving() BUS")

        locationManager.startMonitoring(for: self.region)

        beaconMap += BeaconStorage.getBeaconMap()
        deleteInvisibleBeacons()

        BeaconStorage.writeBeaconMap(map: [:])

        DispatchQueue.main.async {
            _ = Timer.scheduledTimer(withTimeInterval: self.TIMER_INTERVAL, repeats: true) { _ in
                Log.info("Running timer")
                self.inspectBeacons()
            }
        }
    }

    func stopObserving() {
        Log.warning("stopObserving() BUS")

        locationManager.stopMonitoring(for: self.region)
        locationManager.stopRangingBeacons(in: self.region)

        saveState()
    }
    
    func saveState() {
        BeaconStorage.saveCurrentTrip()
        BeaconStorage.writeBeaconMap(map: beaconMap)
    }
    

    // MARK: - Beacon logic

    func inspectBeacons() {
        locationManager(locationManager, didRangeBeacons: [], in: region)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            self.locationManager(self.locationManager, didRangeBeacons: [], in: self.region)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(25)) {
            self.locationManager(self.locationManager, didRangeBeacons: [], in: self.region)
        }
    }

    func deleteInvisibleBeacons() {
        Log.debug("deleteInvisibleBeacons()")

        let currentTrip = BeaconStorage.currentTrip

        for (key, beacon) in beaconMap {
            if beacon.lastSeen + BUS_LAST_SEEN_THRESHOLD < Date().millis() {
                beaconMap.removeValue(forKey: key)

                Log.error("Removed beacon \(key)")

                if currentTrip != nil && currentTrip?.beacon.id == beacon.id {
                    saveTrip(beacon)

                    BeaconStorage.currentTrip = nil
                }
            } else if beacon.lastSeen + TIMEOUT < Date().millis() {
                if currentTrip != nil && currentTrip?.beacon.id == beacon.id {
                    hideCurrentTrip(currentTrip!)
                }
            }
        }
    }

    func currentBusStopOutOfRange(beacon: BusStopBeacon) {
        let currentTrip = BeaconStorage.currentTrip

        if let currentTrip = currentTrip {
            var path = currentTrip.path

            var index = -1
            var i = 0
            let pathSize = path.count

            while i < pathSize {
                let busStop = path[i]
                if busStop.family == beacon.busStop.family {
                    index = i
                    break
                }

                i += 1
            }

            if index == -1 {
                return
            }

            if index < path.count - 1 {
                let newBusStop = path[index + 1]

                currentTrip.beacon.setBusStop(local: newBusStop, type: BusBeacon.TYPE_BEACON)
                currentTrip.update()

                Log.error("Set \(newBusStop.id) \(newBusStop.nameDe) as new bus stop for \(currentTrip.beacon.id)")
            }
        }
    }

    func validateBeacon(beacon: CLBeacon, major: Int, minor: Int) {
        var busBeacon: BusBeacon
        
        if beaconMap[major] != nil {
            busBeacon = beaconMap[major]!
            
            busBeacon.seen()
            busBeacon.distance = beacon.proximity
            
            Log.debug("Vehicle \(major), seen: \(busBeacon.seenSeconds), distance: \(busBeacon.distance.rawValue)")
            
            /*
             * Checks if a beacon needs to download bus info because it is suitable for
             * a trip.
             */
            if busBeacon.origin == 0 && NetUtils.isOnline() &&
                busBeacon.distance.rawValue < CLProximity.far.rawValue {
                
                getBusInformation(beacon: busBeacon)
            }
        } else {
            busBeacon = BusBeacon(id: major)
            
            beaconMap[major] = busBeacon
            
            Log.info("Added vehicle \(major)")
            
            if NetUtils.isOnline() && busBeacon.distance == CLProximity.near {
                getBusInformation(beacon: busBeacon)
            }
        }
    }

    
    // MARK: - Trip

    func updateCurrentTrip() {
        mCycleCounter += 1

        var beacon: BusBeacon!

        for (_, value) in beaconMap {
            if (beacon == nil || value.startDate < beacon.startDate) && value.lastSeen + 30000 > Date().millis() {
                beacon = value
            }
        }

        if beacon == nil || !beacon.isSuitableForTrip {
            return
        }

        let currentTrip = BeaconStorage.currentTrip

        if let currentTrip = currentTrip, currentTrip.beacon.id == beacon.id {
            if beacon.lastSeen + TIMEOUT >= Date().millis() {
                Log.info("Seen: \(beacon.lastSeen + TIMEOUT - Date().millis())")

                currentTrip.beacon = beacon

                /*var currentBusStop = BusStopBeaconHandler.getInstance()
                        .currentBusStop

                if currentBusStop != nil {
                    var path = currentTrip.path

                    for busStop in path {
                        if busStop.group == currentBusStop.busStop.group {
                            beacon.setBusStop(currentBusStop.busStop, BusBeacon.TYPE_BEACON)

                            currentTrip.update()

                            Log.error("Set current bus stop %d for vehicle %d",
                                    busStop.id, beacon.id)

                            break
                        }
                    }
                }*/

                if !currentTrip.isNotificationVisible {
                    currentTrip.update()
                }

                BeaconStorage.currentTrip = currentTrip

                if beacon.shouldFetchDelay() {
                    fetchBusDelayAndInfo(currentTrip: currentTrip)
                }
            }
        } else if mCycleCounter % 10 == 0 && beacon.distance.rawValue <= CLProximity.far.rawValue {
            isBeaconCurrentTrip(beacon: beacon)
            mCycleCounter = 0
        }
    }

    func hideCurrentTrip(_ trip: CurrentTrip) {
        Log.info("hideCurrentTrip()")

        if trip.isNotificationVisible {
            TripNotification.hide(trip: trip)

            getDestinationBusStop(beacon: trip.beacon)

            BeaconStorage.currentTrip = trip
        }
    }

    func saveTrip(_ beacon: BusBeacon) {
        Log.warning("saveTrip()")

        if beacon.seenSeconds < SECONDS_IN_BUS {
            Log.error("Beacon must be visible at least \(SECONDS_IN_BUS) seconds")
            return
        }

        if beacon.destination == 0 {
            Log.error("Trip \(beacon.id) is invalid: destination == 0")
            return
        }

        /*
     * Gets the index of the stop station from the stop list.
     */
        let index = beacon.busStops.index(of: beacon.destination) ?? -1
        if index == -1 {
            Log.error("\(beacon.id) index == -1, destination: \(beacon.destination), busStops: \(beacon.busStops)")

            return
        }

        /*
         * As the realtime api outputs the next station of the trip, we need to
         * go back by one in the trip list. If the bus is at the second bus stop,
         * the api already outputs it at the third.
         */
        if index > 0 {
            beacon.destination = beacon.busStops[index - 1]
        } else {
            beacon.destination = beacon.busStops[index]
        }

        if let trip = Utils.insertTripIfValid(beacon: beacon) {
            if NotificationSettings.isTripEnabled() {
                Notifications.trip(trip: trip)
            }

            Log.warning("Saved trip \(beacon.id)")

            checkForSurvey(beacon: beacon)
        } else {
            Log.error("Could save trip \(beacon.id)")
        }
    }
}

extension BusBeaconHandler: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        Log.warning("didEnterRegion() BUS")
        manager.startRangingBeacons(in: self.region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        Log.warning("didExitRegion() BUS")
        
        // Clear all beacon maps
        BeaconStorage.writeBeaconMap(map: [:])
        
        deleteInvisibleBeacons()
        
        let currentTrip = BeaconStorage.currentTrip
        if currentTrip != nil {
            hideCurrentTrip(currentTrip!)
        }
        
        inspectBeacons()
        
        manager.stopRangingBeacons(in: self.region)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        deleteInvisibleBeacons()
        
        if beacons.isEmpty {
            return
        }
        
        Log.debug("didRangeBeacons(): BUS, count: \(beacons.count)")
        
        for beacon in beacons {
            let major = beacon.major as! Int
            let minor = beacon.minor as! Int
            
            validateBeacon(beacon: beacon, major: major, minor: minor)
        }
        
        updateCurrentTrip()
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        Log.error("Monitoring beacons failed: \(error)")
    }
}

extension BusBeaconHandler {
    
    func getBusInformation(beacon: BusBeacon) {
        guard !beacon.isOriginPending else {
            return
        }
        
        if !beacon.canRetry() {
            beacon.setSuitableForTrip(false)
            return
        }
        
        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }
        
        Log.warning("getBusInformation \(beacon.id)")
        
        beacon.isOriginPending = true
        beacon.retry()
        
        _ = RealtimeApi.vehicle(beacon.id)
            .subscribeOn(MainScheduler.background)
            .observeOn(MainScheduler.background)
            .subscribe(onNext: { bus in
                guard let bus: RealtimeBus = bus else {
                    Log.error("Vehicle \(beacon.id) not driving")
                    
                    beacon.setSuitableForTrip(false)
                    beacon.isOriginPending = false
                    
                    return
                }
                
                Log.error("getBusInformation: \(bus.busStop)")
                
                let busStopsPath = Api.getTrip(tripId: bus.trip).calcPath()
                var path = busStopsPath.map {
                    $0.id
                }
                
                if path.isEmpty {
                    beacon.isOriginPending = false
                    beacon.setSuitableForTrip(false)
                    
                    Log.error("Triplist for \(beacon.id) null or empty")
                    
                    return
                }
                
                beacon.origin = bus.busStop
                beacon.departure = bus.departure
                
                beacon.addLine(line: bus.lineId)
                beacon.addTrip(trip: bus.trip)
                beacon.addVariant(variant: bus.variant)
                
                beacon.setBusStop(realm: BusStopRealmHelper.getBusStop(id: bus.busStop), type: BusBeacon.TYPE_REALTIME)
                
                beacon.setBusStops(busStops: path)
                
                beacon.delay = bus.delay
                beacon.updateLastDelayFetch()
                
                let destination = BusStopRealmHelper
                    .getName(id: path[path.count - 1])
                
                beacon.title = "Line \(bus.lineName) to \(destination)"
                
                let hash = HashUtils.getHashForTrip(beacon: beacon)
                beacon.setHash(hash: hash)
                
                Log.warning("Got bus info for \(beacon.id), bus stop \(bus.busStop)")
                
                beacon.setSuitableForTrip(true)
                beacon.isOriginPending = false
            }, onError: { error in
                Utils.logError(error, message: "getBusInformation() error: \(error)")
                
                beacon.isOriginPending = false
                beacon.setSuitableForTrip(false)
            })
    }
    
    func isBeaconCurrentTrip(beacon: BusBeacon) {
        Log.warning("isBeaconCurrentTrip()")
        
        if beacon.isCurrentTripPending {
            return
        }
        
        if beacon.seenSeconds > MIN_NOTIFICATION_SECONDS {
            Log.warning("Added trip because it was in range for more than \(MIN_NOTIFICATION_SECONDS)s")
            
            BeaconStorage.currentTrip = CurrentTrip(beacon: beacon)
            
            return
        }
        
        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }
        
        beacon.isCurrentTripPending = true
        
        _ = RealtimeApi.vehicle(beacon.id)
            .subscribe(onNext: { bus in
                guard let bus: RealtimeBus = bus else {
                    Log.error("isBeaconCurrentTrip() bus \(beacon.id) not driving")
                    return
                }
                
                beacon.isCurrentTripPending = false
                
                Log.error("isBeaconCurrentTrip(): \(bus.busStop)")
                
                if beacon.origin != bus.busStop {
                    Log.error("Setting new bus stop for \(beacon.id)")
                    
                    beacon.setBusStop(realm: BusStopRealmHelper
                        .getBusStop(id: bus.busStop), type: BusBeacon.TYPE_REALTIME)
                    
                    BeaconStorage.currentTrip = CurrentTrip(beacon: beacon)
                }
            }, onError: { error in
                Utils.logError(error, message: "isBeaconCurrentTrip() error: \(error)")
                
                beacon.isCurrentTripPending = false
            })
    }
    
    func fetchBusDelayAndInfo(currentTrip: CurrentTrip) {
        Log.warning("fetchBusDelayAndInfo()")
        
        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }
        
        let beacon: BusBeacon = currentTrip.beacon
        beacon.updateLastDelayFetch()
        
        _ = RealtimeApi.vehicle(beacon.id)
            .subscribeOn(MainScheduler.background)
            .observeOn(MainScheduler.background)
            .subscribe(onNext: { bus in
                guard let bus: RealtimeBus = bus else {
                    Log.error("Vehicle \(beacon.id) not driving")
                    return
                }
                
                Log.warning("Got bus delay for vehicle \(currentTrip.id): \(bus.delay)")
                
                let realmStop = BusStopRealmHelper.getBusStopOrNil(id: bus.busStop)
                if let stop = realmStop {
                    beacon.setBusStop(realm: stop, type: BusBeacon.TYPE_REALTIME)
                    
                    Log.warning("Got bus stop for vehicle \(currentTrip.id): \(stop.id) \(stop.nameDe!)")
                }
                
                beacon.delay = bus.delay
                beacon.departure = bus.departure
                
                if beacon.lastTrip != bus.trip {
                    Log.error("Trip reset for vehicle \(beacon.id)")
                    
                    // Assume that the bus changed variant (probably because it arrived at
                    // its destination), so reset the trip by clearing the old path and times.
                    
                    let newTrip = bus.trip
                    let newLine = bus.lineId
                    let newVariant = bus.variant
                    
                    Log.error("Old trip: \(beacon.lastTrip), new trip: \(newTrip)")
                    Log.error("Old line: \(beacon.lastLine), new line: \(newLine)")
                    Log.error("Old variant: \(beacon.lastVariant), new variant: \(newVariant)")
                    
                    beacon.addLine(line: newLine)
                    beacon.addTrip(trip: newTrip)
                    beacon.addVariant(variant: newVariant)
                    
                    let busStopsPath: [VdvBusStop] = Api.getTrip(tripId: bus.trip).calcPath()
                    var path = busStopsPath.map {
                        $0.id
                    }
                    
                    if path.isEmpty {
                        beacon.isOriginPending = false
                        beacon.setSuitableForTrip(false)
                        
                        Log.error("New trip list for \(beacon.id) null or empty")
                        
                        return
                    }
                    
                    beacon.appendBusStops(stops: path)
                    
                    let destination = BusStopRealmHelper.getName(id: path[path.count - 1])
                    
                    beacon.title = "Line \(bus.lineName) to \(destination)"
                    
                    currentTrip.reset()
                }
                
                currentTrip.update()
            }, onError: { error in
                Utils.logError(error, message: "fetchBusDelayAndInfo() error: \(error)")
            })
    }
    
    func getDestinationBusStop(beacon: BusBeacon) {
        Log.error("getDestinationBusStop \(beacon.id)")
        
        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }
        
        _ = RealtimeApi.vehicle(beacon.id)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .retryWhen { (errors: Observable<Error>) in
                return errors.flatMapWithIndex { (error, attempts) -> Observable<Int64> in
                    if attempts >= 3 - 1 {
                        return Observable.error(error)
                    }
                    
                    return Observable<Int64>.timer(RxTimeInterval((attempts + 1) * 5), scheduler: MainScheduler.asyncInstance)
                }
            }
            .subscribe(onNext: { bus in
                guard let bus: RealtimeBus = bus else {
                    return
                }
                
                beacon.destination = bus.busStop
                
                Log.error("Stop station for \(beacon.id): \(bus.busStop)")
            }, onError: { error in
                Utils.logError(error)
            })
    }
}

extension BusBeaconHandler {
    
    func checkForSurvey(beacon: BusBeacon) {
        Log.warning("checkForSurvey()")
        
        guard NotificationSettings.areSurveysEnabled() else {
            Log.error("Surveys are disabled")
            return
        }
        
        Log.info("Surveys are enabled")
        
        let lastSurvey = NotificationSettings.getLastSurveyMillis()
        var showSurvey = false
        
        switch NotificationSettings.getSurveyInterval() {
        case 0: // Show every time
            Log.info("Survey interval: every time")
            showSurvey = true
        case 1: // Once a day
            Log.info("Survey interval: once a day")
            
            if Date().millis() - lastSurvey > 1 * 24 * 60 * 60 * 1000 {
                showSurvey = true
            }
        case 2: // Once a week
            Log.info("Survey interval: once a week")
            
            if Date().millis() - lastSurvey > 7 * 24 * 60 * 60 * 1000 {
                showSurvey = true
            }
        case 3: // Once a month
            Log.info("Survey interval: once a month")
            
            if Date().millis() - lastSurvey > Int64(30 * 24 * 60 * 60) * Int64(1000) {
                showSurvey = true
            }
        default: break
        }
        
        if showSurvey {
            Log.warning("Showing survey")
            
            // TODO check if this works
            Notifications.survey(hash: beacon.tripHash)
            NotificationSettings.setLastSurveyMillis(millis: Date().millis())
        }
    }
}
