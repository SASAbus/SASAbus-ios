//
// Created by Alex Lardschneider on 27/03/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

final class Parking: JSONable, JSONCollection {

    let id: Int

    let name: String
    let address: String
    let phone: String

    let lat: Double
    let lng: Double

    let freeSlots: Int
    let totalSlots: Int

    var location: CLLocation {
        get {
            return CLLocation(latitude: lat, longitude: lng)
        }
    }

    required init(parameter: JSON) {
        id = parameter["id"].intValue

        name = parameter["name"].stringValue
        address = parameter["address"].stringValue
        phone = parameter["phone"].stringValue

        lat = parameter["latitude"].doubleValue
        lng = parameter["longitude"].doubleValue

        freeSlots = parameter["free"].intValue
        totalSlots = parameter["total"].intValue
    }

    static func collection(parameter: JSON) -> [Parking] {
        var items: [Parking] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(Parking(parameter: itemRepresentation))
        }

        return items
    }
}