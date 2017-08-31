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
                "fcm_token": FcmSettings.getFcmToken()
        ]

        return RestClient.post(Endpoint.USER_LOGIN, parameters: parameters)
    }

    static func loginGoogle(userId: String) -> Observable<JSON> {
        let parameters = [
            "user_id": userId,
            "fcm_token": FcmSettings.getFcmToken()
        ]

        return RestClient.post(Endpoint.USER_LOGIN_GOOGLE, parameters: parameters)
    }


    static func logout() -> Observable<Void?> {
        let parameters = [
                "fcm_token": FcmSettings.getFcmToken()
        ]

        return RestClient.post(Endpoint.USER_LOGOUT, parameters: parameters)
    }

    static func logoutAll() -> Observable<Void?> {
        return RestClient.post(Endpoint.USER_LOGOUT_ALL)
    }

    static func delete() -> Observable<Void?> {
        return RestClient.delete(Endpoint.USER_DELETE)
    }
}
