import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class LinesApi {
    
    static func filterLines(lines: String) -> Observable<JSON> {
        return Observable<JSON>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request(Endpoint.API + Endpoint.LINES_FILTER + lines, method: .get)
                .responseJSON(completionHandler: { (response) in
                    if let value = response.result.value {
                        observer.onNext(JSON(value))
                        observer.onCompleted()
                    } else if let error = response.result.error {
                        observer.onError(error)
                    }
                })
            return Disposables.create {
                requestReference.cancel()
            }
        }
    }
}
