import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class BusBeaconHandler: NSObject, CLLocationManagerDelegate {

    private var MAX_BEACON_DISTANCE = 5
    private var BUS_LAST_SEEN_THRESHOLD = 180000
    private var SECONDS_IN_BUS = 90
    private var MIN_NOTIFICATION_SECONDS = 60

    private var TIMEOUT = 10000

    private let UUID_STRING = "e923b236-f2b7-4a83-bb74-cfb7fa44cab8"
    private let IDENTIFIER = "BUS"

    private let locationManager = CLLocationManager()
    private var region: CLBeaconRegion!
    private var regions: Dictionary<String, CLBeaconRegion> = Dictionary<String, CLBeaconRegion>()
    private var didEnterRegionDate: Date?
    private var didExitRegionDate: Date?

    private var mCycleCounter = 0

    private var beaconMap = [Int: BusBeacon]()

    override init() {
        super.init()

        self.locationManager.delegate = self

        self.region = CLBeaconRegion(proximityUUID: UUID(uuidString: UUID_STRING)!, identifier: IDENTIFIER)
        self.region.notifyEntryStateOnDisplay = true
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
    }

    func startObserving() {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }

        Log.warning("startObserving() BUS")

        locationManager.startMonitoring(for: self.region)
        locationManager.startRangingBeacons(in: self.region)
    }


    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            Log.info("Beacon #\(beacon.major), distance: \(beacon.proximity.rawValue)")
        }

        deleteInvisibleBeacons()

        var firstBeacon: BusBeacon? = nil

        for (_, beacon) in beaconMap {
            if (firstBeacon == nil || beacon.getStartDate().millis() < (firstBeacon?.getStartDate().millis())!) &&
                       beacon.lastSeen + 30000 > Date().millis() {

                firstBeacon = beacon
            }
        }

        if let firstBeacon = firstBeacon {
            if firstBeacon.isSuitableForTrip {
                if BeaconStorage.hasCurrentTrip() && BeaconStorage.getCurrentTrip()?.beacon?.id == firstBeacon.id {

                    if firstBeacon.lastSeen + TIMEOUT >= Date().millis() {
                        Log.info("Seen: \(firstBeacon.lastSeen + TIMEOUT - Date().millis())")

                        let currentTrip: CurrentTrip = BeaconStorage.getCurrentTrip()!
                        currentTrip.setBeacon(beacon: firstBeacon)

                        /*Pair<Integer, BusStop> currentBusStop = BusStopBeaconHandler.getInstance(mContext)
                        .getCurrentBusStop();
                        if (currentBusStop != null) {
                            List<BusStop> path = currentTrip.getPath();
                            
                            for (BusStop busStop : path) {
                                if (busStop.getGroup() == currentBusStop.second.getGroup()) {
                                    firstBeacon.setBusStop(currentBusStop.second, currentBusStop.first);
                                    currentTrip.update();
                                    
                                    Timber.e("Set current bus stop %d for vehicle %d",
                                             busStop.getId(), firstBeacon.id);
                                    
                                    break;
                                }
                            }
                        }*/

                        if !currentTrip.isNotificationShown && currentTrip.beacon!.isSuitableForTrip &&
                                   Settings.isBusNotificationEnabled() {

                            currentTrip.setNotificationShown(shown: true)

                            //notificationAction.showNotification(currentTrip);
                        }

                        if firstBeacon.shouldFetchDelay() {
                            fetchBusDelayAndInfo(trip: currentTrip)
                        }

                        BeaconStorage.setCurrentTrip(trip: currentTrip)
                    }
                } else if mCycleCounter % 3 == 0/* && firstBeacon.distance <= MAX_BEACON_DISTANCE*/ {
                    isBeaconCurrentTrip(beacon: firstBeacon)
                    mCycleCounter = 0
                }
            }
        }

        mCycleCounter += 1

        BeaconStorage.writeBeaconMap(map: beaconMap)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let now = Date()

        if didEnterRegionDate == nil || now.timeIntervalSince1970 - (didEnterRegionDate?.timeIntervalSince1970)! > 2 {
            didEnterRegionDate = now

            Log.warning("didEnterRegion() BUS")
            locationManager.startRangingBeacons(in: self.region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let now = Date()

        if didExitRegionDate == nil || now.timeIntervalSince1970 - (didExitRegionDate?.timeIntervalSince1970)! > 2 {
            didExitRegionDate = now

            Log.warning("didExitRegion() BUS")
            locationManager.stopRangingBeacons(in: self.region)
        }
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

    func validateBeacon(beacon: CLBeacon, major: Int, minor: Int) {
        var busBeacon: BusBeacon

        if beaconMap[major] != nil {
            busBeacon = beaconMap[major]!

            busBeacon.seen()
            busBeacon.setDistance(distance: beacon.proximity.rawValue)

            Log.info("Vehicle \(major), seen: \(busBeacon.seenSeconds), distance: \(busBeacon.distance)")

            /*
             * Checks if a beacon needs to download bus info because it is suitable for
             * a trip.
             */
            if busBeacon.origin == 0 && NetUtils.isOnline() &&
                       busBeacon.distance <= MAX_BEACON_DISTANCE {

                getBusInformation(beacon: busBeacon)
            }
        } else {
            busBeacon = BusBeacon(id: major, hash: "")

            beaconMap[major] = busBeacon

            Log.info("Added vehicle \(major)")

            if NetUtils.isOnline() && busBeacon.distance <= MAX_BEACON_DISTANCE {
                getBusInformation(beacon: busBeacon)
            }
        }
    }

    func getBusInformation(beacon: BusBeacon) {
        guard !beacon.isOriginPending else {
            return
        }

        if !beacon.canRetry() {
            beacon.setSuitableForTrip(suitableForTrip: false)
            return
        }

        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }

        Log.warning("getBusInformation \(beacon.id)")

        beacon.setOriginPending(pending: true)
        beacon.retry()

        _ = RealtimeApi.vehicle(vehicle: beacon.id)
                .subscribeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { bus in
                    guard let bus: RealtimeBus = bus else {

                        Log.error("Vehicle \(beacon.id) not driving")

                        beacon.setSuitableForTrip(suitableForTrip: false)
                        beacon.setOriginPending(pending: false)

                        return
                    }

                    Log.info("getBusInformation: \(bus.busStop)")

                    let path: [Int] = bus.path

                    if path.isEmpty {
                        beacon.setOriginPending(pending: false)
                        beacon.setSuitableForTrip(suitableForTrip: false)

                        Log.warning("Triplist for \(beacon.id) empty")

                        return
                    }

                    beacon.setOrigin(origin: bus.busStop)
                    beacon.addLine(line: bus.lineId)
                    beacon.addTrip(trip: bus.trip)
                    beacon.addVariant(variant: bus.variant)
                    beacon.setFuelPrice(price: 1.35)
                    beacon.departure = bus.departure

                    beacon.setBusStop(busStop: BusStopRealmHelper.getBusStop(id: bus.busStop), type: BusBeacon.TYPE_REALTIME)

                    beacon.setBusStops(busStops: path)

                    beacon.setDelay(delay: bus.delay)
                    beacon.updateLastDelayFetch()

                    let destination = BusStopRealmHelper.getName(id: path.last!)

                    // var title = mContext.getString(R.string.notification_bus_title, Lines.lidToName(bus.lineId), destination);
                    let title = "Line \(bus.lineName) to \(destination)"

                    beacon.setTitle(title: title)

                    let hash = "1234123412341234"
                    //var hash = HashUtils.getHashForTrip(beacon);
                    beacon.tripHash = hash

                    Log.warning("Got bus info for \(beacon.id), bus stop \(bus.busStop)")

                    beacon.setSuitableForTrip(suitableForTrip: true)
                    beacon.setOriginPending(pending: false)
                }, onError: { error in
                    Log.error("getBusInformation() error: \(error)")
                    //Utils.logException(e);

                    beacon.setOriginPending(pending: false)
                    beacon.setSuitableForTrip(suitableForTrip: false)
                })
    }

    func deleteInvisibleBeacons() {
        Log.info("deleteInvisibleBeacons()")

        let currentTrip = BeaconStorage.getCurrentTrip()

        for (key, beacon) in beaconMap {
            if beacon.lastSeen + BUS_LAST_SEEN_THRESHOLD < Date().millis() {
                beaconMap.removeValue(forKey: key)

                Log.warning("Removed beacon \(key)")

                if BeaconStorage.hasCurrentTrip() && currentTrip?.getId() == beacon.id {
                    //addTrip(beacon)

                    BeaconStorage.setCurrentTrip(trip: nil)
                }
            } else if beacon.lastSeen + TIMEOUT < Date().millis() {
                if let trip = currentTrip {
                    if trip.isNotificationShown && trip.getId() == beacon.id {
                        trip.setNotificationShown(shown: false)
                        trip.setBeacon(beacon: beacon)

                        Log.warning("Dismissing notification for \(key)")

                        //NotificationUtils.cancelBus(mContext);

                        //getStopStation(beacon);

                        BeaconStorage.setCurrentTrip(trip: trip)
                    }
                }
            }
        }
    }

    func addTrip(beacon: BusBeacon) {
        if beacon.seenSeconds < SECONDS_IN_BUS {
            Log.error("Beacon must be visible at least \(SECONDS_IN_BUS) seconds")
            return
        }

        if beacon.destination == 0 {
            Log.error("\(beacon.id) destination == 0")
            return
        }

        /*
         * Gets the index of the stop station from the stop list.
         */
        let index = beacon.busStops.index(of: beacon.destination)
        if index == nil {
            Log.error("\(beacon.id) index == nil, stopStation: \(beacon.destination), stopList: \(beacon.busStops)")
            return
        }

        /*
         * As the realtime api outputs the next station of the trip, we need to
         * go back by one in the trip list. If the bus is at the second bus stop,
         * the api already outputs it at the third.
         */
        if index! > 0 {
            beacon.setDestination(destination: beacon.busStops[index! - 1])
        } else {
            beacon.setDestination(destination: beacon.busStops[index!])
        }

        if Utils.insertTripIfValid(beacon: beacon) && Settings.isTripNotificationEnabled() {
            //NotificationUtils.trip(mContext, beacon.getHash());

            Log.warning("Saved trip \(beacon.id)")

            if Settings.isSurveyEnabled() {
                Log.info("Survey is enabled")

                let interval = Settings.getSurveyInterval()
                let lastSurvey = Settings.getLastSurveyMillis()
                var showSurvey = false

                switch interval {
                case 0: // Show every time
                    Log.info("Survey interval: every time")

                    showSurvey = true
                case 1: // Once a day
                    Log.info("Survey interval: once a day")

                    if Date().millis() - lastSurvey > 86400000 {
                        showSurvey = true
                    }
                case 2: // Once a week
                    Log.info("Survey interval: once a week")

                    if Date().millis() - lastSurvey > 604800000 {
                        showSurvey = true
                    }
                case 3: // Once a month
                    Log.info("Survey interval: once a month")

                    if Int64(Date().millis() - lastSurvey) > (2_592_000_000 as Int64) {
                        showSurvey = true
                    }
                default:
                    Log.error("Unknown survey interval: \(interval)")
                }

                if showSurvey {
                    Log.warning("Showing survey")

                    //NotificationUtils.survey(mContext, beacon.getHash());

                    Settings.setLastSurveyMillis(millis: Date().millis())
                }
            }
        } else {
            Log.error("Could not save trip \(beacon.id)")
        }
    }

    func isBeaconCurrentTrip(beacon: BusBeacon) {
        Log.warning("isBeaconCurrentTrip()")

        if beacon.isCurrentTripPending {
            return
        }

        if beacon.seenSeconds > MIN_NOTIFICATION_SECONDS {
            Log.warning("Added trip because it was in range for more than \(MIN_NOTIFICATION_SECONDS)s")

            BeaconStorage.setCurrentTrip(trip: CurrentTrip(beacon: beacon))

            return
        }

        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }

        beacon.setCurrentTripPending(pending: true)

        _ = RealtimeApi.vehicle(vehicle: beacon.id)
                .subscribeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { bus in
                    beacon.setCurrentTripPending(pending: false)

                    guard let bus: RealtimeBus = bus else {
                        Log.error("isBeaconCurrentTrip() buses empty")
                        return
                    }

                    Log.info("isBeaconCurrentTrip() response: \(bus.busStop)")

                    if beacon.origin != bus.busStop {
                        Log.info("Setting new bus stop for \(beacon.id)")

                        if BeaconStorage.hasCurrentTrip() && BeaconStorage.getCurrentTrip()?.beacon?.id != beacon.id {
                            let preBeaconInfo = BeaconStorage.getCurrentTrip()?.beacon
                            self.addTrip(beacon: preBeaconInfo!)
                        }

                        beacon.setBusStop(busStop: BusStop(value: BusStopRealmHelper
                                .getBusStop(id: bus.busStop)), type: BusBeacon.TYPE_REALTIME)

                        BeaconStorage.setCurrentTrip(trip: CurrentTrip(beacon: beacon))

                        // Cancel all bus stop notifications
                        /*for (int i = 0; i < 6000; i++) {
                            NotificationUtils.cancel(mContext, i);
                        }*/
                    }
                }, onError: { error in
                    Log.error("isBeaconCurrentTrip() error: \(error)")

                    beacon.setCurrentTripPending(pending: false)
                })
    }

    func getStopStation(beacon: BusBeacon) {
        Log.warning("getStopStation \(beacon.id)")

        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }

        _ = RealtimeApi.vehicle(vehicle: beacon.id)
                .subscribeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { bus in
                    guard let bus: RealtimeBus = bus else {
                        Log.error("Unable to get stop station for bus \(beacon.id)")
                        return
                    }

                    beacon.setDestination(destination: bus.busStop)

                    Log.info("Stop station for \(beacon.id): \(bus.busStop)")
                }, onError: { error in
                    Log.error("getStopStation() error: \(error)")
                })
    }

    func fetchBusDelayAndInfo(trip: CurrentTrip) {
        Log.warning("fetchBusDelayAndInfo()")

        if !NetUtils.isOnline() {
            Log.error("No internet connection")
            return
        }

        let beacon: BusBeacon = trip.beacon!
        beacon.updateLastDelayFetch()

        _ = RealtimeApi.vehicle(vehicle: beacon.id)
                .subscribeOn(MainScheduler.asyncInstance)
                .subscribe(onNext: { bus in
                    guard let bus: RealtimeBus = bus else {
                        Log.error("Vehicle \(beacon.id) not driving")
                        return
                    }

                    Log.info("Got bus delay for vehicle \(beacon.id): \(bus.delay)")

                    let realmStop = BusStopRealmHelper.getBusStopOrNil(id: bus.busStop)

                    if let stop = realmStop {
                        let busStop = BusStop(value: stop)
                        beacon.setBusStop(busStop: busStop, type: BusBeacon.TYPE_REALTIME)
                        Log.info("Got bus stop for vehicle \(beacon.id): \(busStop.id) \(busStop.nameDe)")
                    }

                    beacon.setDelay(delay: bus.delay)

                    if beacon.getLastTrip() != bus.trip {
                        Log.warning("Trip reset for vehicle \(beacon.id)")

                        // Assume that the bus changed variant (probably because it arrived at
                        // its destination), so reset the trip by clearing the old path and times.

                        let newTrip = bus.trip
                        let newLine = bus.lineId
                        let newVariant = bus.variant

                        Log.info("Old trip: \(beacon.getLastTrip()), new trip: \(newTrip)")
                        Log.info("Old line: \(beacon.getLastLine()), new line: \(newLine)")
                        Log.info("Old variant: \(beacon.getLastVariant()), new variant: \(newVariant)")

                        beacon.addLine(line: newLine)
                        beacon.addTrip(trip: newTrip)
                        beacon.addVariant(variant: newVariant)

                        beacon.departure = bus.departure

                        let path = bus.path
                        beacon.appendBusStops(busStops: path)

                        let destination = BusStopRealmHelper.getName(id: path.last!)

                        /*var title = mContext.getString(R.string.notification_bus_title,
                            Lines.lidToName(bus.lineId), destination);*/

                        let title = "Line \(bus.lineName) heading to \(destination)"
                        beacon.setTitle(title: title)

                        trip.reset()
                    }
                }, onError: { error in
                    Log.error("fetchBusDelayAndInfo() error: \(error)")
                })
    }

    func currentBusStopOutOfRange(currentBusStop: BusStop) {
        if BeaconStorage.hasCurrentTrip() {
            let currentTrip: CurrentTrip = BeaconStorage.getCurrentTrip()!

            var path = currentTrip.getPath()

            var index = -1
            for i in 0 ..< path.count {
                let busStop = path[i]
                if busStop.family == currentBusStop.family {
                    index = i
                    break
                }
            }

            if index == -1 {
                return
            }

            if index < path.count - 1 {
                let newBusStop = path[index + 1]

                currentTrip.beacon?.setBusStop(busStop: newBusStop, type: BusBeacon.TYPE_BEACON)
                currentTrip.update()

                Log.info("Set \(newBusStop.id) \(newBusStop.nameDe) as new bus stop for \(currentTrip.getId())")
            }
        }
    }
}
