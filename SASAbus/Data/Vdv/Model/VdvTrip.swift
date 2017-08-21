//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

/**
 * Represents a tripId identifiable by an unique ID, in JSON format described with the parameter
 * 'FRT_FID'. This parameter is only unique for one day. It might repeat on another day.
 *
 * @author David Dejori
 */

class VdvTrip: Hashable {

    static let empty = VdvTrip(lineId: 0, variant: 0, departure: 0, timeGroup: 0, tripId: 0)

    let lineId: Int
    let variant: Int
    let departure: Int
    let timeGroup: Int
    public let tripId: Int

    var path: [VdvBusStop]?

    init(lineId: Int, variant: Int, departure: Int, timeGroup: Int, tripId: Int) {
        self.lineId = lineId
        self.variant = variant
        self.departure = departure
        self.timeGroup = timeGroup
        self.tripId = tripId
    }

    func calcPath() -> [VdvBusStop] {
        VdvHandler.blockTillLoaded()

        if path == nil {
            path = VdvPaths.getPath(lineId: lineId, variant: variant)
        }

        return path!
    }

    func calcTimedPath() -> [VdvBusStop] {
        var path = calcPath()

        if !path.isEmpty {
            path[0].departure = departure

            for i in 1...path.count - 1 {
                let last = path[i - 1]
                let current = path[i]

                current.departure = last.departure +
                        VdvIntervals.getInterval(timeGroup: timeGroup, origin: last.id, destination: current.id) +
                        VdvBusStopBreaks.getStopTime(timeGroup: timeGroup, busStop: current.id) +
                        VdvTripBreaks.getStopTime(tripId: tripId, busStop: current.id)
            }

            return path
        }

        return []
    }

    public static func ==(lhs: VdvTrip, rhs: VdvTrip) -> Bool {
        if lhs == rhs {
            return true
        }

        if lhs.lineId != rhs.lineId {
            return false
        }

        if lhs.variant != rhs.variant {
            return false
        }

        if lhs.departure != rhs.departure {
            return false
        }

        if lhs.timeGroup != rhs.timeGroup {
            return false
        }

        return lhs.tripId == rhs.tripId
    }

    var hashValue: Int {
        var result = lineId
        result = 31 * result + variant
        result = 31 * result + departure
        result = 31 * result + timeGroup
        result = 31 * result + tripId
        result = 31 * result + (path != nil ? path!.count : 0)
        return result
    }

    public var description: String {
        return "\(tripId)"
    }
}
