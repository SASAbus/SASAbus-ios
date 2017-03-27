import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class NewsApi {

    static func news() -> Observable<[NewsItem]> {
        return RestClient.get(Endpoint.NEWS, index: "news")
    }
}
