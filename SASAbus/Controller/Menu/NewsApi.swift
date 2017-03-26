import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class NewsApi {

    static func news() -> Observable<[NewsItem]> {
        return Observable<[NewsItem]>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request(Endpoint.API + Endpoint.NEWS, method: .get)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            let json = JSON(response.result.value)["news"]

                            var news: [NewsItem] = []
                            if let newsArray = json.to(type: NewsItem.self) {
                                news = newsArray as! [NewsItem]
                            }

                            observer.onNext(news)
                            observer.onCompleted()
                        } else {
                            observer.onError(response.error!)
                        }
                    })
            return Disposables.create {
                requestReference.cancel()
            }
        }
    }
}
