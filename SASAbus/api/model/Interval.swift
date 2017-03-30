import Foundation

class Interval: Hashable {
    
    let fgr: Int
    let busStop1: Int
    let busStop2: Int
    
    var hashValue: Int {
        var result = fgr
        result = 31 * result + busStop1
        result = 31 * result + busStop2
        return result
    }
    
    init(fgr: Int, busStop1: Int, busStop2: Int) {
        self.fgr = fgr
        self.busStop1 = busStop1
        self.busStop2 = busStop2
    }
}

func == (lhs: Interval, rhs: Interval) -> Bool {
    return lhs.fgr == rhs.fgr && lhs.busStop1 == rhs.busStop1 && lhs.busStop2 == rhs.busStop2
}
