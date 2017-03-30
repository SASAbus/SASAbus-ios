import Foundation

/**
 * Represents a trip identifiable by an unique ID, in JSON format described with the parameter
 * 'FRT_FID'. This parameter is only unique for one day. It might repeat on another day.
 *
 * @author David Dejori
 */
class Trip: Hashable {
    
    private let line: Int
    private let variant: Int
    private let day: Int
    private let time: Int
    private let fgr: Int
    fileprivate let trip: Int
    private var secondsAtUserStop: Int
    
    var hashValue: Int {
        return trip
    }
    
    init(line: Int, variant: Int, day: Int, time: Int, fgr: Int, trip: Int) {
        self.line = line
        self.variant = variant
        self.day = day
        self.time = time
        self.fgr = fgr
        self.trip = trip
        
        secondsAtUserStop = 0
    }
    
    func getPath() -> [ApiBusStop] {
        let path: [ApiBusStop] = Paths.getPath(line: line, variant: variant)
    
        path[0].setSeconds(seconds: time)
    
        for i in 1..<path.count {
            let stopSeconds1 = HaltTimes.getStopSeconds(trip: trip, stop: path[i].getId())
            let stopSeconds2 = StopTimes.getStopSeconds(fgr: fgr, stop: path[i].getId() + stopSeconds1)
            
            let interval = Intervals.getInterval(
                fgr: fgr,
                busStop1: path[i - 1].getId(),
                busStop2: path[i].getId()
            ) + stopSeconds2
            
            let seconds = path[i - 1].getSeconds() + interval
    
            path[i].setSeconds(seconds: seconds)
        }
    
        return path
    }
    
    func getSecondsAtStation(busStopId: Int) -> Int {
        for busStop in getPath() {
            if busStop.getId() == busStopId {
                secondsAtUserStop = busStop.getSeconds()
                return secondsAtUserStop
            }
        }
        
        return -1
    }
    
    func getLine() -> Int {
        return line
    }
    
    func getVariant() -> Int {
        return variant
    }
    
    func getDay() -> Int {
        return day
    }
    
    func getTime() -> Int {
        return time
    }
    
    func getTrip() -> Int {
        return trip
    }
    
    func getSecondsAtUserStop() -> Int {
        return secondsAtUserStop
    }
}

func == (lhs: Trip, rhs: Trip) -> Bool {
    return lhs.trip == rhs.trip
}
