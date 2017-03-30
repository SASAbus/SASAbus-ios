import Foundation
import SwiftyJSON

final class LeaderboardPlayer: JSONable, JSONCollection {

    let id: String
    let username: String

    let points: Int
    let profile: Int

    required init(parameter: JSON) {
        id = parameter["id"].stringValue
        username = parameter["username"].stringValue

        points = parameter["points"].intValue
        profile = parameter["profile"].intValue
    }

    static func collection(parameter: JSON) -> [LeaderboardPlayer] {
        var items: [LeaderboardPlayer] = []

        for itemRepresentation in parameter.arrayValue {
            items.append(LeaderboardPlayer(parameter: itemRepresentation))
        }

        return items
    }
}
