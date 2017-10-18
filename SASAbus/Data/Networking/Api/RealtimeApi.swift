import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class RealtimeApi {

    static func get() -> Observable<[RealtimeBus]> {
        return RestClient.get(Endpoint.REALTIME, index: "buses")
    }

    static func line(_ line: Int) -> Observable<[RealtimeBus]> {
        return RestClient.get(Endpoint.REALTIME_LINE + String(line), index: "buses")
    }

    static func lines(_ lines: [String]) -> Observable<[RealtimeBus]> {
        let param = lines.joined(separator: ",")
        return RestClient.get(Endpoint.REALTIME_LINE + param, index: "buses")
    }

    static func vehicle(_ vehicle: Int) -> Observable<RealtimeBus?> {
        return RestClient.get(Endpoint.REALTIME_VEHICLE + String(vehicle), index: "buses")
    }

    static func delays() -> Observable<[RealtimeBus]> {
        return RestClient.get(Endpoint.REALTIME_DELAYS, index: "buses")
    }
}
