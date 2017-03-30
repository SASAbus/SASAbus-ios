import Foundation

/**
 * Represents the stop time of a bus at a specific stop.
 *
 * @author Alex Lardschneider
 */
class StopTime: Hashable {
    
    let id: Int
    let stop: Int
    
    var hashValue: Int {
        var result = id
        result = 31 * result + stop
        return result
    }
    
    init(id: Int, stop: Int) {
        self.id = id
        self.stop = stop
    }
}

func == (lhs: StopTime, rhs: StopTime) -> Bool {
    return lhs.id == rhs.id && lhs.stop == rhs.stop
}
