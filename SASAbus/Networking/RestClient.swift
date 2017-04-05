import Foundation
import Alamofire
import RxSwift
import RxCocoa
import SwiftyJSON

class RestClient {

    static func get<T: JSONable>(_ url: String, index: String) -> Observable<T?> {
        return Observable<T?>.create { observer -> Disposable in
            let requestReference = getInternal(url)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            let json = JSON(response.result.value)

                            let item = json[index].arrayValue

                            if item.isEmpty {
                                observer.on(.next(nil))
                            } else {
                                let casted = item[0].to(type: T.self) as? T
                                observer.onNext(casted)
                            }

                            observer.onCompleted()
                        } else {
                            observer.onError(response.result.error!)
                        }
                    })

            return Disposables.create {
                requestReference.cancel()
            }
        }
    }

    static func get<T: JSONable>(_ url: String, index: String) -> Observable<[T]> {
        return Observable<[T]>.create { observer -> Disposable in
            let requestReference = getInternal(url)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            let json = JSON(response.result.value)

                            var items: [T] = []
                            if let item = json[index].to(type: T.self) {
                                items = item as! [T]
                            }

                            observer.onNext(items)

                            observer.onCompleted()
                        } else {
                            observer.onError(response.result.error!)
                        }
                    })

            return Disposables.create {
                requestReference.cancel()
            }
        }
    }

    static func post(_ url: String, parameters: [String : String]) -> Observable<JSON> {
        return Observable<JSON>.create { observer -> Disposable in
            let requestReference = postInternal(url, parameters: parameters)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            let json = JSON(response.result.value)
                            observer.onNext(json)
                            observer.onCompleted()
                        } else {
                            observer.onError(response.result.error!)
                        }
                    })

            return Disposables.create {
                requestReference.cancel()
            }
        }
    }


    // - MARK: Internal network requests

    static func getInternal(_ endpoint: String, parameters: Parameters? = nil) -> Alamofire.DataRequest {
        let url = "\(Endpoint.API)\(endpoint)"

        let headers = getHeaders(url)
        return request(url, method: .get, parameters: parameters, headers: headers)
    }

    static func postInternal(_ endpoint: String, parameters: Parameters? = nil) -> Alamofire.DataRequest {
        let url = "\(Endpoint.API)\(endpoint)"

        let headers = getHeaders(url)
        return request(url, method: .post, parameters: parameters, headers: headers)
    }

    static func request(_ url: URLConvertible, method: HTTPMethod, parameters: Parameters? = nil,
                        headers: [String : String]) -> Alamofire.DataRequest {

        Log.debug("\(method.rawValue.uppercased()): \(url)")

        return Alamofire.request(url, method: method, parameters: parameters, headers: headers)
    }


    // - MARK: Headers

    static func getHeaders(_ url: URLConvertible) -> [String : String] {
        let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

        var headers = [
                "User-Agent": "SasaBus iOS",
                "X-Device": DeviceUtils.getModel(),
                "X-Language": Utils.locale(),
                "X-Version-Code": versionCode,
                "X-Version-Name": versionName,
                "X-Android-Id": DeviceUtils.getIdentifier(),
                "X-Serial": "empty"
        ]

        if requiresAuthHeader(try! url.asURL().pathComponents) {
            let token = AuthHelper.getTokenIfValid()

            if let token = token {
                headers["Authorization"] = "Bearer \(token)"
            } else {
                Log.error("Token is invalid")
            }
        }

        return headers
    }

    static func requiresAuthHeader(_ segments: [String]) -> Bool {
        if segments.count <= 3 {
            return false
        }

        let path = segments[2]
        let segment = segments[3]

        if path == "eco" || path == "sync" {
            return true
        }

        if path == "auth" {
            if segment == "password" || segment == "logout" || segment == "delete" {
                return true
            }
        }

        return false
    }
}
