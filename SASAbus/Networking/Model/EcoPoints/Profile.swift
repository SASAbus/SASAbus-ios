import Foundation
import SwiftyJSON

final class Profile: JSONable, JSONCollection {

    let id: String
    let username: String

    let cls: String

    let points: Int
    let badges: Int
    let rank: Int
    let profile: Int

    required init(parameter: JSON) {
        id = parameter["id"].stringValue
        username = parameter["username"].stringValue
        cls = parameter["class"].stringValue

        points = parameter["points"].intValue
        badges = parameter["badges"].intValue
        rank = parameter["rank"].intValue
        profile = parameter["profile"].intValue
    }

    static func collection(parameter: JSON) -> [Profile] {
        var items: [Profile] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(Profile(parameter: itemRepresentation))
        }

        return items
    }
}
