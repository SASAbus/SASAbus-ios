import Foundation
import ObjectMapper

class BusStopBeacon: AbsBeacon {

    var isNotificationShown: Bool = false

    var busStop: BusStop!


    override init(id: Int) {
        busStop = BusStopRealmHelper.getBusStop(id: id)

        super.init(id: id)
    }

    required init?(map: Map) {
        super.init(map: map)
    }

    // Mappable
    override func mapping(map: Map) {
        super.mapping(map: map)

        busStop <- map["busStop"]
        isNotificationShown <- map["isNotificationShown"]
    }

    func setNotificationShown() {
        isNotificationShown = true
    }
}
