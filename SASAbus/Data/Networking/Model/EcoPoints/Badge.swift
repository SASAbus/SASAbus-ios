import Foundation
import SwiftyJSON

final class Badge: JSONable, JSONCollection {

    let id: String
    let title: String
    let description: String

    let iconUrl: String

    let progress: Int
    let points: Int
    let users: Int

    let isNewBadge: Bool

    let locked: Bool

    required init(parameter: JSON) {
        id = parameter["id"].stringValue
        title = parameter["title"].stringValue
        description = parameter["description"].stringValue

        iconUrl = parameter["icon_url"].stringValue

        progress = parameter["progress"].intValue
        points = parameter["points"].intValue
        users = parameter["users"].intValue

        isNewBadge = parameter["new"].boolValue
        locked = parameter["locked"].boolValue
    }

    static func collection(parameter: JSON) -> [Badge] {
        var items: [Badge] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(Badge(parameter: itemRepresentation))
        }

        return items
    }
}
