//
// Created by Alex Lardschneider on 05/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import SwiftyJSON

class CloudApi {

    static func uploadTrips(trips: [CloudTrip]) -> Observable<JSON> {
        let jsonString = Mapper().toJSONString(trips)

        return RestClient.postBody(Endpoint.CLOUD_TRIPS, json: jsonString!)
    }
}
