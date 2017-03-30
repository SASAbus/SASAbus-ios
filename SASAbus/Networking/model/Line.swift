//
// Created by Alex Lardschneider on 24/03/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

import UIKit
import SwiftyJSON

final class Line: JSONable, JSONCollection {

    let id: Int
    let days: Int

    let name: String
    let shortName: String

    let origin: String
    let destination: String

    let city: String
    let info: String

    fileprivate let zone: String

    let variants: [Int]

    required init(parameter: JSON) {
        id = parameter["id"].int ?? parameter["LI_NR"].intValue
        days = parameter["days"].intValue

        name = parameter["name"].string ?? parameter["LIDNAME"].stringValue
        shortName = parameter["LI_KUERZEL"].stringValue

        origin = parameter["origin"].stringValue
        destination = parameter["destination"].stringValue

        city = parameter["city"].stringValue
        info = parameter["info"].stringValue
        zone = parameter["zone"].stringValue

        variants = parameter["varlist"].arrayValue.map {
            $0.intValue
        }
    }

    init(shortName: String, name: String, variants: [Int], number: Int) {
        self.id = number

        self.name = name
        self.shortName = shortName

        self.variants = variants

        days = 0

        origin = ""
        destination = ""

        city = ""
        info = ""
        zone = ""
    }

    static func collection(parameter: JSON) -> [Line] {
        var items: [Line] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(Line(parameter: itemRepresentation))
        }

        return items
    }

    func getArea() -> String {
        let shortNameParts = shortName.characters.split {
            $0 == " "
        }

        switch String(shortNameParts[0]) {
        case "201":
            return "OTHER"
        case "248":
            return "OTHER"
        case "300":
            return "OTHER"
        case "5000":
            return "OTHER"
        case "227":
            return "ME"
        default:
            break
        }

        if shortNameParts.count > 1 {
            return String(shortNameParts[1])
        } else {
            return "OTHER"
        }
    }
}
