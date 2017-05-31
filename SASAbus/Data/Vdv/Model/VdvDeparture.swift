//
// Created by Alex Lardschneider on 29/05/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

/**
 * Represents a tripId identifiable by an unique ID, in JSON format described with the parameter
 * 'FRT_FID'. This parameter is only unique for one day. It might repeat on another day.
 *
 * @author David Dejori
 */

class VdvDeparture: CustomStringConvertible {

    let lineId: Int
    let time: Int
    let destination: VdvBusStop
    let tripId: Int

    init(lineId: Int, time: Int, destination: VdvBusStop, tripId: Int) {
        self.lineId = lineId
        self.time = time
        self.destination = destination
        self.tripId = tripId
    }

    private var line: String {
        return Lines.lidToName(id: lineId)
    }

    private func getTime() -> String {
        return ApiTime.toTime(seconds: time)
    }

    func asDeparture(busStopId: Int) -> Departure {
        let busStop = BusStopRealmHelper.getBusStop(id: busStopId)

        return Departure(
                lineId: lineId,
                trip: tripId,
                busStopGroup: busStop.family,
                line: line,
                time: getTime(),
                destination: BusStopRealmHelper.getName(id: destination.id)
        )
    }

    public var description: String {
        return "VdvDeparture{" +
                "lineId='\(lineId)'," +
                "time='\(time)'," +
                "destination='\(destination)'," +
                "tripId='\(tripId)'" +
                "}"
    }
}

extension VdvDeparture: Comparable {

    static func ==(lhs: VdvDeparture, rhs: VdvDeparture) -> Bool {
        return lhs.lineId == rhs.lineId &&
                lhs.time == rhs.time &&
                lhs.destination == rhs.destination &&
                lhs.tripId == rhs.tripId
    }

    static func <(lhs: VdvDeparture, rhs: VdvDeparture) -> Bool {
        return lhs.time < rhs.time
    }
}
