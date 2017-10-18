import Foundation
import ObjectMapper

class BusBeacon: AbsBeacon {

    static var TYPE_BEACON = 0
    static var TYPE_REALTIME = 1

    var DELAY_FETCH_INTERVAL = 30000

    var tripHash: String = ""

    var title: String = ""

    var lastDelayFetch: Int64 = 0

    var lines = [Int]()
    var trips = [Int]()
    var variants = [Int]()

    var delay: Int = 0
    var origin: Int = 0
    var destination: Int = 0
    var departure: Int = 0
    var busStopType: Int = 0

    var retryCount: Int = 0

    var busStops = [Int]()

    var isOriginPending: Bool = false
    var isCurrentTripPending: Bool = false
    var isSuitableForTrip: Bool = false

    var busStop: BBusStop?


    override init(id: Int) {
        super.init(id: id)

        seen()
    }

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)

        tripHash <- map["tripHash"]
        title <- map["title"]
        lastDelayFetch <- map["lastDelayFetch"]

        lines <- map["lines"]
        trips <- map["trips"]
        variants <- map["variants"]

        delay <- map["delay"]
        origin <- map["origin"]
        destination <- map["destination"]
        departure <- map["departure"]
        busStopType <- map["busStopType"]

        retryCount <- map["retryCount"]
        busStops <- map["busStops"]

        isOriginPending <- map["isOriginPending"]
        isCurrentTripPending <- map["isCurrentTripPending"]
        isSuitableForTrip <- map["isSuitableForTrip"]

        busStop <- map["busStop"]
    }


    func canRetry() -> Bool {
        return retryCount < 3
    }

    func shouldFetchDelay() -> Bool {
        return lastDelayFetch + DELAY_FETCH_INTERVAL < Date().millis()
    }

    func setBusStops(busStops: [Int]) {
        self.busStops.removeAll()
        self.busStops.append(contentsOf: busStops)
    }

    func appendBusStops(stops: [Int]) {
        var busStops = stops

        if busStops.isEmpty {
            Log.error("BusStops null or empty")
            return
        }

        if self.busStops[self.busStops.count - 1] == busStops[0] {
            busStops = Array(busStops[1...busStops.count - 1])
        }

        self.busStops.append(contentsOf: busStops)
    }

    func retry() {
        retryCount += 1
    }

    func updateLastDelayFetch() {
        lastDelayFetch = Date().millis()
    }

    func setHash(hash: String) {
        self.tripHash = hash

        Log.info("Set hash \(hash) for trip \(id)")
    }


    func setBusStop(realm: BusStop, type: Int) {
        setBusStop(local: BBusStop(fromRealm: realm), type: type)
    }

    func setBusStop(local: BBusStop, type: Int) {
        self.busStop = local
        self.busStopType = type

        // Also set the end bus stop in case the "normal" fetching for the end bus stop fails.
        destination = busStop!.id
    }


    // ======================================= ATOMIC ==============================================

    func setSuitableForTrip(_ suitableForTrip: Bool) {
        if !suitableForTrip {
            Log.error("Beacon is not suitable for a trip, dismissing notification")

            TripNotification.hide(trip: nil)
        }

        isSuitableForTrip = suitableForTrip
    }


    // ======================================== LISTS ==============================================

    func addLine(line: Int) {
        lines.append(line)
    }

    func addVariant(variant: Int) {
        variants.append(variant)
    }

    func addTrip(trip: Int) {
        trips.append(trip)
    }

    var lastTrip: Int {
        get {
            return trips.isEmpty ? 0 : trips[trips.count - 1]
        }
    }

    var lastVariant: Int {
        get {
            return variants.isEmpty ? 0 : variants[variants.count - 1]
        }
    }

    var lastLine: Int {
        get {
            return lines.isEmpty ? 0 : lines[lines.count - 1]
        }
    }
}
