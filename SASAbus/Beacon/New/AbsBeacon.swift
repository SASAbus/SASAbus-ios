//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

class AbsBeacon: Mappable {

    var id: Int!

    var startDate = Date()

    var seenSeconds: Int64 = 0
    var lastSeen: Int64 = 0

    var distance: CLProximity = .unknown

    init(id: Int) {
        self.id = id

        seen()
    }

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        id <- map["id"]
        startDate <- (map["startDate"], DateTransform())
        seenSeconds <- map["seenSeconds"]
        lastSeen <- map["lastSeen"]
        distance <- map["distance"]
    }

    func seen() {
        let millis = Date().millis()

        seenSeconds = (millis - startDate.millis()) / 1000
        lastSeen = millis
    }
}
