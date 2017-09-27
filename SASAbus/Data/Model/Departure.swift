import Foundation

class Departure {

    static let NO_DELAY = 1 << 12
    static let OPERATION_RUNNING = 1 << 11

    let lineId: Int
    let trip: Int
    let busStopGroup: Int

    let line: String
    let destination: String

    let time: String
    var formattedTime: NSAttributedString?

    var delay: Int = 0
    var vehicle: Int = 0
    var currentBusStop: Int = 0

    init(lineId: Int, trip: Int, busStopGroup: Int, line: String, time: String, destination: String) {
        self.lineId = lineId
        self.trip = trip
        self.line = line
        self.time = time
        self.busStopGroup = busStopGroup
        self.destination = destination

        delay = Departure.OPERATION_RUNNING
    }
}
