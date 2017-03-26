import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class UserApi {
    
    static func login(email: String, password: String) -> Observable<JSON> {
        return Observable<JSON>.create { (observer) -> Disposable in
            
            let parameters = [
                "email": email,
                "password": password,
                "fcm_token": ""
            ]
            
           /* let requestReference = RestClient.withHeaders(Endpoint.API + Endpoint.USER_LOGIN, method: .post, parameters: parameters)
                .responseJSON(completionHandler: { (response) in
                    if let value = response.result.value {
                        observer.onNext(JSON(value))
                        observer.onCompleted()
                    } else if let error = response.result.error {
                        observer.onError(error)
                    }
                })*/
            
            return Disposables.create {
                // requestReference.cancel()
            }
        }
    }
}
