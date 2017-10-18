import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import SwiftyJSON

class CloudApi {

    static func uploadTrips(trips: [CloudTrip]) -> Observable<JSON> {
        let jsonString = Mapper().toJSONString(trips)

        return RestClient.putBody(Endpoint.CLOUD_TRIPS, json: jsonString!)
    }
}
