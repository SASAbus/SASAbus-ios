import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class RealtimeApi {
    
    static func line(line: Int) -> Observable<JSON> {
        return Observable<JSON>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request("\(Endpoint.API)\(Endpoint.REALTIME_LINE)\(line)", method: .get)
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
    
    static func vehicle(vehicle: Int) -> Observable<RealtimeBus> {
        return Observable<RealtimeBus>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request("\(Endpoint.API)\(Endpoint.REALTIME_VEHICLE)\(vehicle)", method: .get)
                .responseJSON(completionHandler: { (response) in
                    if let value = response.result.value {
                        let json = JSON(value)

                        var news: [RealtimeBus] = []
                        if let newsArray = json["data"].to(type: RealtimeBus.self) {
                            news = newsArray as! [RealtimeBus]
                        }

                        observer.onNext(news.first!)
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
    
    static func delays() -> Observable<JSON> {
        return Observable<JSON>.create { (observer) -> Disposable in
            let requestReference = Alamofire.request("\(Endpoint.API)\(Endpoint.REALTIME_DELAYS)", method: .get)
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
