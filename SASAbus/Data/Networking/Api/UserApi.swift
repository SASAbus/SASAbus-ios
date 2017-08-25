import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class UserApi {

    static func login(email: String, password: String) -> Observable<JSON> {
        // TODO: FCM token

        let parameters = [
                "email": email,
                "password": password,
                "fcm_token": ""
        ]

        return RestClient.post(Endpoint.USER_LOGIN, parameters: parameters)
    }

    static func loginGoogle(userId: String) -> Observable<JSON> {
        // TODO: FCM token

        let parameters = [
            "user_id": userId,
            "fcm_token": ""
        ]

        return RestClient.post(Endpoint.USER_LOGIN_GOOGLE, parameters: parameters)
    }


    static func logout(fcmToken: String?) -> Observable<Void?> {
        // TODO: FCM token

        let parameters = [
                "fcm_token": fcmToken
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
