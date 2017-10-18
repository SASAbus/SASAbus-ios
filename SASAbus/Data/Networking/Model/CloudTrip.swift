//
// Created by Alex Lardschneider on 05/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import ObjectMapper

class CloudTrip: Mappable, Hashable {

    var hash: String!

    var lines: [Int]!
    var variants: [Int]!
    var trips: [Int]!

    var vehicle: Int!

    var origin: Int!
    var destination: Int!

    var departure: Int64!
    var arrival: Int64!

    var path: [Int]!

    init(trip: Trip) {
        hash = trip.tripHash

        lines = trip.getLinesAsList()
        variants = trip.getVariantsAsList()
        trips = trip.getTripsAsList()

        vehicle = trip.vehicle
        origin = trip.origin
        destination = trip.destination
        departure = trip.departure
        arrival = trip.arrival
        path = trip.path!.components(separatedBy: Config.DELIMITER).map {
            Int($0)!
        }
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        hash <- map["hash"]
        lines <- map["lines"]
        variants <- map["variants"]
        trips <- map["trips"]

        vehicle <- map["vehicle"]
        origin <- map["origin"]
        destination <- map["destination"]
        departure <- map["departure"]
        arrival <- map["arrival"]
        path <- map["path"]
    }


    var hashValue: Int {
        return hash.hashValue
    }

    public static func ==(lhs: CloudTrip, rhs: CloudTrip) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
