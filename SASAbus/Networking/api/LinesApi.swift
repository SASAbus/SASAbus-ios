import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class LinesApi {
    
    static func filterLines(lines: String) -> Observable<[Line]> {
        return RestClient.get(Endpoint.LINES_FILTER + String(lines), index: "lines")
    }
}
