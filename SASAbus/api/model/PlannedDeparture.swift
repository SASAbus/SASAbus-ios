import Foundation

/**
 * Represents a departure from a bus stop, not considering the real-time delays. This only uses
 * the planned offline open data (in JSON format) of SASA SpA-AG.
 *
 * @author David Dejori
 */
class PlannedDeparture {
    
    private let line: Int
    private let time: Int
    private let trip: Int
    
    init(line: Int, time: Int, trip: Int) {
        self.line = line
        self.time = time
        self.trip = trip
    }
    
    func getLine() -> Int {
        return line
    }
    
    func getTime() -> Int {
        return time
    }
    
    func getTrip() -> Int {
        return trip
    }
    
    /*@Override
    public String toString() {
        return "PlannedDeparture{" +
            "line=" + line +
            ", time=" + ApiUtils.getTime(time) +
            ", trip=" + trip +
            '}';
    }*/
}
