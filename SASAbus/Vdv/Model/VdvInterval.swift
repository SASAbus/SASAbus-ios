import Foundation

/**
 * Represents a time interval between two bus stops.
 */
class VdvInterval {

    var timeGroup: Int
    var origin: Int
    var destination: Int

    init(timeGroup: Int, origin: Int, destination: Int) {
        self.timeGroup = timeGroup
        self.origin = origin
        self.destination = destination
    }
}

extension VdvInterval: Hashable {

    var hashValue: Int {
        var result = timeGroup
        result = 31 * result + origin
        result = 31 * result + destination
        return result
    }

    public static func ==(lhs: VdvInterval, rhs: VdvInterval) -> Bool {
        if lhs.timeGroup != rhs.timeGroup {
            return false
        }

        if lhs.origin != rhs.origin {
            return false
        }

        return lhs.destination == rhs.destination
    }
}
