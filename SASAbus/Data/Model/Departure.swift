import Foundation
import ObjectMapper

class Departure: Mappable {

    static let NO_DELAY = 1 << 12
    static let OPERATION_RUNNING = 1 << 11

    var lineId: Int = 0
    var trip: Int = 0
    var busStopGroup: Int = 0

    var line: String = ""
    var destination: String = ""

    var time: String = ""
    var formattedTime: NSAttributedString? = nil

    var delay: Int = 0
    var vehicle: Int = 0
    var currentBusStop: Int = 0

    
    required convenience init?(map: Map) {
        self.init(lineId: 0, trip: 0, busStopGroup: 0, line: "", time: "", destination: "")

    }
    
    init(lineId: Int, trip: Int, busStopGroup: Int, line: String, time: String, destination: String) {
        self.lineId = lineId
        self.trip = trip
        self.line = line
        self.time = time
        self.busStopGroup = busStopGroup
        self.destination = destination

        delay = Departure.OPERATION_RUNNING
    }

    
    func mapping(map: Map) {
        lineId <- map["lineId"]
        trip <- map["trip"]
        
        busStopGroup <- map["busStopGroup"]
        line <- map["line"]
        destination <- map["destination"]
        time <- map["time"]
        
        delay <- map["delay"]
        vehicle <- map["vehicle"]
        currentBusStop <- map["currentBusStop"]
    }
}
