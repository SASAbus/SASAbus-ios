import Foundation

class BusStopBeacon: AbsBeacon {

    var isNotificationShown: Bool = false

    var busStop: BusStop


    override init(id: Int) {
        busStop = BusStopRealmHelper.getBusStop(id: id)

        super.init(id: id)
    }

    public required init() {
        fatalError("init() in BusStopBeacon not implemented")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) in BusStopBeacon not implemented")
    }


    /**
     * Sets [.isNotificationShown] to `true`.
     */
    func setNotificationShown() {
        isNotificationShown = true
    }
}
