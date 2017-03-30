import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class ParkingApi {

    static func get() -> Observable<[Parking]> {
        return RestClient.get(Endpoint.PARKING, index: "parking")
    }
}
