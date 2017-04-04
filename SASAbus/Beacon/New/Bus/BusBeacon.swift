import Foundation

class BusBeacon: AbsBeacon {

    static var TYPE_BEACON = 0
    static var TYPE_REALTIME = 1

    private var DELAY_FETCH_INTERVAL = 30000

    var tripHash: String?

    var title: String?

    private var lastDelayFetch: Int64 = 0

    var lines = [Int]()
    var trips = [Int]()
    var variants = [Int]()

    var delay: Int = 0
    var origin: Int = 0
    var destination: Int = 0
    var departure: Int = 0
    var busStopType: Int = 0

    private var retryCount: Int = 0

    var busStops = [Int]()

    private var mOriginPending: Bool = false
    private var mCurrentTripPending: Bool = false
    private var mSuitableForTrip: Bool = false

    var busStop: BusStop?


    override init(id: Int) {
        super.init(id: id)

        seen()
    }

    public required init() {
        fatalError("init() in BusBeacon not implemented")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) in BusBeacon not implemented")
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

    func setBusStop(_ busStop: BusStop, type: Int) {
        self.busStop = busStop
        self.busStopType = type

        // Also set the end bus stop in case the "normal" fetching for the end bus stop fails.
        destination = busStop.id
    }

    func updateLastDelayFetch() {
        lastDelayFetch = Date().millis()
    }

    func setHash(hash: String) {
        self.tripHash = hash

        Log.info("Set hash %s for trip %s", hash, id)
    }


// ======================================= ATOMIC ==============================================

    var isOriginPending: Bool {
        get {
            return mOriginPending
        }
        set {
            mOriginPending = newValue
        }
    }

    var isSuitableForTrip: Bool {
        get {
            return mSuitableForTrip
        }
    }

    func setSuitableForTrip(_ suitableForTrip: Bool) {
        if !suitableForTrip {
            Log.error("Beacon is not suitable for a trip, dismissing notification")

            // TODO
            // TripNotification.hide(context, null)
        }

        mSuitableForTrip = suitableForTrip
    }

    var isCurrentTripPending: Bool {
        get {
            return mCurrentTripPending
        }
        set {
            mCurrentTripPending = newValue
        }
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

extension Date {

    func millis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }

    func seconds() -> Int {
        return Int(timeIntervalSince1970)
    }
}
