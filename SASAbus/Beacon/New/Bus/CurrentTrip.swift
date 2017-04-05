import Foundation
import ObjectMapper

class CurrentTrip: Mappable {

    var beacon: BusBeacon!

    var isNotificationVisible: Bool = false

    var hasReachedSecondBusStop: Bool = false

    var path = [LocalBusStop]()
    var times: [VdvBusStop]?

    var id: Int {
        get {
            return beacon.id
        }
    }

    var delay: Int {
        get {
            return beacon.delay
        }
    }

    var title: String {
        get {
            return beacon.title
        }
    }


    init(beacon: BusBeacon) {
        self.beacon = beacon

        // Check for badge
        // TODO
        // BadgeHelper.evaluate(mContext!!, beacon)

        setup()
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        beacon <- map["beacon"]
        isNotificationVisible <- map["isNotificationVisible"]
        hasReachedSecondBusStop <- map["hasReachedSecondBusStop"]
        path <- map["path"]
        times <- map["times"]
    }



    func update() {
        if beacon.isSuitableForTrip {
            Log.error("Updating current trip notification")

            TripNotification.show(trip: self)
        } else {
            Log.error("Cannot update current trip notification because trip is not suitable")
        }
    }

    func reset() {
        Log.error("Trip reset")
        setup()
    }

    private func setup() {
        path.removeAll()

        if times != nil {
            times!.removeAll()
        }

        hasReachedSecondBusStop = false

        DispatchQueue(label: "com.app.queue", qos: .background).async {
            let newTimes = Api2.getTrip(tripId: self.beacon.lastTrip, verifyUiThread: false).calcTimedPath()
            if newTimes.isEmpty {
                Log.error("Trips for trip %s do not exist", self.beacon.lastTrip)

                self.beacon.setSuitableForTrip(false)

                TripNotification.hide(trip: self)
            } else {
                self.times = Array(newTimes)

                for busStop in self.times! {
                    self.path.append(LocalBusStop(realm: BusStopRealmHelper.getBusStop(id: busStop.id)))
                }
            }
        }
    }
}
