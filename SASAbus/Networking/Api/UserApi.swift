import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class UserApi {

    static func login(email: String, password: String) -> Observable<JSON> {
        let parameters = [
                "email": email,
                "password": password,
                "fcm_token": ""
        ]

        return RestClient.post(Endpoint.USER_LOGIN, parameters: parameters)
    }
}
