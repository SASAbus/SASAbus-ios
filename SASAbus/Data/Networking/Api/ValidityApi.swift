import Foundation

import RxSwift
import RxCocoa

import SwiftyJSON

class ValidityApi {
    
    static func checkData(unix: Int) -> Observable<JSON> {
        return RestClient.getJson("\(Endpoint.VALIDITY_DATA)\(unix)")
    }
}
