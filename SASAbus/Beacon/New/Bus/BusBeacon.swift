import Foundation

class BusBeacon: Serializable {

    static let TYPE_BEACON = 0
    static let TYPE_REALTIME = 1

    //private static final long DELAY_FETCH_INTERVAL = TimeUnit.SECONDS.toMillis(30);

    let DELAY_FETCH_INTERVAL = 30000

    var tripHash: String = ""
    var title: String?

    var id: Int = 0

    var startTimeMillis: Int64 = 0

    var distance: Int = 0
    var fuelPrice: Double = 0

    var lastSeen: Int64 = 0
    var lastDelayFetch: Int64 = 0
    var seenSeconds: Int = 0

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

    var busStop: BusStop?

    convenience init(id: Int, hash: String) {
        self.init()

        self.id = id
        self.tripHash = hash

        startTimeMillis = Date().millis()

        seen()
    }

    func seen() {
        let now = Date()

        seenSeconds = Int((now.millis() - startTimeMillis)) / 1000
        lastSeen = now.millis()
    }

    func getStartDate() -> Date {
        return Date(timeIntervalSince1970: Double(startTimeMillis) / Double(1000))
    }

    func addLine(line: Int) {
        lines.append(line)
    }

    func addVariant(variant: Int) {
        variants.append(variant)
    }

    func addTrip(trip: Int) {
        trips.append(trip)
    }

    func getLines() -> [Int] {
        return lines
    }

    func getVariants() -> [Int] {
        return variants
    }

    func getTrips() -> [Int] {
        return trips
    }

    func getLastTrip() -> Int {
        return trips.isEmpty ? 0 : trips.last!
    }

    func getLastVariant() -> Int {
        return variants.isEmpty ? 0 : variants.last!
    }

    func getLastLine() -> Int {
        return lines.isEmpty ? 0 : lines.last!
    }

    func setTitle(title: String) {
        self.title = title
    }

    func setDelay(delay: Int) {
        self.delay = delay
    }

    func canRetry() -> Bool {
        return retryCount < 3
    }

    func shouldFetchDelay() -> Bool {
        return lastDelayFetch + DELAY_FETCH_INTERVAL < Date().millis()
    }

    func setDistance(distance: Int) {
        self.distance = distance
    }

    func setOrigin(origin: Int) {
        self.origin = origin
    }

    func setOriginPending(pending: Bool) {
        isOriginPending = pending
    }

    func setCurrentTripPending(pending: Bool) {
        isCurrentTripPending = pending
    }

    func setFuelPrice(price: Double) {
        self.fuelPrice = price
    }

    func setBusStops(busStops: [Int]) {
        self.busStops.removeAll()
        self.busStops.append(contentsOf: busStops)
    }

    func appendBusStops(busStops: [Int]) {
        guard busStops.isEmpty else {
            Log.error("BusStops null or empty")
            return
        }

        // TODO
        /*if self.busStops.last! == busStops.first! {
            busStops = busStops.subList(1, busStops.size());
        }*/

        self.busStops.append(contentsOf: busStops)
    }

    func setDestination(destination: Int) {
        self.destination = destination
    }

    func retry() {
        retryCount += 1
    }

    func setSuitableForTrip(suitableForTrip: Bool) {
        if !suitableForTrip {
            Log.error("Beacon is not suitable for a trip, dismissing notification")

            //NotificationUtils.cancelBus(context);
        }

        isSuitableForTrip = suitableForTrip
    }

    func setBusStop(busStop: BusStop, type: Int) {
        self.busStop = busStop
        self.busStopType = type

        // Also set the end bus stop in case the "normal" fetching for the end bus stop fails.
        destination = busStop.id
    }

    func updateLastDelayFetch() {
        lastDelayFetch = Date().millis()
    }
}

extension Date {

    func millis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
