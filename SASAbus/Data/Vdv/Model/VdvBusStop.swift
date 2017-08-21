//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 * Represents a bus stop.
 */
class VdvBusStop: Hashable, Mappable {

    var id: Int = 0
    var departure: Int = 0

    init(id: Int) {
        self.id = id
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        id <- map["id"]
        departure <- map["departure"]
    }

    var hashValue: Int {
        return id
    }

    var time: String {
        get {
            return ApiTime.toTime(seconds: departure)
        }
    }

    public var description: String {
        return "\(id)"
    }

    public static func ==(lhs: VdvBusStop, rhs: VdvBusStop) -> Bool {
        return lhs.id == rhs.id
    }
}
