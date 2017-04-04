import Foundation
import EVReflection

class CurrentTrip: EVObject {

    var beacon: BusBeacon!

    init(beacon: BusBeacon) {
        self.beacon = beacon

        super.init()

        // Check for badge
        // TODO
        // BadgeHelper.evaluate(mContext!!, beacon)

        setup()
    }

    public required init() {
        fatalError("init() in CurrentTrip not implemented")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) in CurrentTrip not implemented")
    }


    private var mNotificationVisible: Bool = false

    var hasReachedSecondBusStop: Bool = false

    var path = [BusStop]()
    var times: [VdvBusStop]?

    private func setup() {
        path.removeAll()

        if times != nil {
            times!.removeAll()
        }

        hasReachedSecondBusStop = false

        let newTimes = Api2.getTrip(tripId: beacon.lastTrip, verifyUiThread: false).calcTimedPath()
        if newTimes.isEmpty {
            Log.error("Trips for trip %s do not exist", beacon.lastTrip)

            beacon.setSuitableForTrip(false)

            // TODO
            // TripNotification.hide(mContext!!, this)
        } else {
            times = Array(newTimes)

            for busStop in times! {
                path.append(BusStopRealmHelper.getBusStop(id: busStop.id))
            }
        }
    }

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

    func update() {
        if beacon.isSuitableForTrip && isNotificationVisible {
            // TODO
            // TripNotification.show(mContext!!, this)
        }
    }

    func reset() {
        Log.error("Trip reset")
        setup()
    }

    var title: String {
        get {
            return beacon.title!
        }
    }


// ==================================== NOTIFICATION ===========================================

    var isNotificationVisible: Bool {
        get {
            return mNotificationVisible
        }
        set {
            mNotificationVisible = newValue
        }
    }
}
