import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class EcoPointsApi {

    static func getProfile() -> Observable<Profile?> {
        return RestClient.get(Endpoint.ECO_POINTS_PROFILE, index: "profile")
    }

    static func getLeaderboard(page: Int) -> Observable<[LeaderboardPlayer]> {
        return RestClient.get("\(Endpoint.ECO_POINTS_LEADERBOARD)\(page)", index: "leaderboard")
    }

    /* static func getAllBadges() -> Observable<JSON> {
        // return RestClient.request(Endpoint.API + Endpoint.ECO_POINTS_BADGES, method: .get)
    } */

    static func getNextBadges() -> Observable<[Badge]> {
        return RestClient.get(Endpoint.ECO_POINTS_BADGES_NEXT, index: "badges")
    }

    static func getEarnedBadges() -> Observable<[Badge]> {
        return RestClient.get(Endpoint.ECO_POINTS_BADGES_EARNED, index: "badges")
    }

    static func sendBadge(id: Int) -> Observable<Any?> {
        return RestClient.putNoResponse("\(Endpoint.ECO_POINTS_BADGES_SEND)\(id)")
    }
}
