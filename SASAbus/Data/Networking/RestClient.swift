import Foundation
import Alamofire
import RxSwift
import RxCocoa
import SwiftyJSON

class RestClient {

    // - MARK: Internal network requests

    static func getInternal(_ endpoint: String, parameters: Parameters? = nil) -> Alamofire.DataRequest {
        return request(endpoint, method: .get, parameters: parameters)
    }

    static func postInternal(_ endpoint: String, parameters: Parameters? = nil) -> Alamofire.DataRequest {
        return request(endpoint, method: .post, parameters: parameters)
    }

    static func putInternal(_ endpoint: String, parameters: Parameters? = nil) -> Alamofire.DataRequest {
        return request(endpoint, method: .put, parameters: parameters)
    }

    static func deleteInternal(_ endpoint: String, parameters: Parameters? = nil) -> Alamofire.DataRequest {
        return request(endpoint, method: .delete, parameters: parameters)
    }

    static func request(_ endpoint: String, method: HTTPMethod, parameters: Parameters? = nil) -> Alamofire.DataRequest {
        var host = Endpoint.apiUrl
        
        if endpoint.starts(with: "realtime") {
            host = Endpoint.realtimeApiUrl
        }
        
        let url = host + endpoint
        let headers = getHeaders(url)

        Log.debug("\(method.rawValue.uppercased()): \(url)")

        return Alamofire.request(url, method: method, parameters: parameters, headers: headers)
    }


    // - MARK: Headers

    static func getHeaders(_ url: URLConvertible) -> [String : String] {
        let versionCode = Bundle.main.versionCode
        let versionName = Bundle.main.versionName

        var headers = [
                "User-Agent": "SasaBus iOS",
                "X-Device": DeviceUtils.getModel(),
                "X-Language": Locales.get(),
                "X-Version-Code": versionCode,
                "X-Version-Name": versionName,
                "X-Android-Id": DeviceUtils.getIdentifier()
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


extension RestClient {

    static func get<T:JSONable>(_ url: String, index: String) -> Observable<T?> {
        return Observable<T?>.create { observer -> Disposable in
            let requestReference = getInternal(url)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            let json = JSON(response.result.value)

                            if json[index].exists() {
                                let items = json[index].arrayValue
                                
                                if !items.isEmpty {
                                    let casted = items[0].to(type: T.self) as? T
                                    observer.on(.next(casted))
                                } else {
                                    let casted = json[index].to(type: T.self) as? T
                                    observer.on(.next(casted))
                                }
                            } else {
                                observer.onError(Errors.json(message: "Index '\(index)' does not exist in JSON for url '\(url)'"))
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

    static func get<T:JSONable>(_ url: String, index: String) -> Observable<[T]> {
        return Observable<[T]>.create { observer -> Disposable in
            let requestReference = getInternal(url)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            let json = JSON(response.result.value)

                            var items: [T] = []
                            if let cast = json[index].to(type: T.self) as? [T] {
                                items = cast
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

    static func getJson(_ url: String) -> Observable<JSON> {
        return Observable<JSON>.create { observer -> Disposable in
            let requestReference = getInternal(url)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            observer.onNext(JSON(response.result.value))
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
}

extension RestClient {

    static func post(_ url: String, parameters: Parameters? = nil) -> Observable<JSON> {
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

    static func post(_ url: String, parameters: Parameters? = nil) -> Observable<Void?> {
        return Observable<Void?>.create { observer -> Disposable in
            let requestReference = postInternal(url, parameters: parameters)
                    .response(completionHandler: { response in
                        if response.error == nil {
                            observer.onNext(nil)
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

extension RestClient {

    static func delete(_ url: String, parameters: Parameters? = nil) -> Observable<Void?> {
        return Observable<Void?>.create { observer -> Disposable in
            let requestReference = deleteInternal(url, parameters: parameters)
                    .response(completionHandler: { response in
                        if response.error == nil {
                            observer.onNext(nil)
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

extension RestClient {

    static func put<T:JSONable>(_ url: String, index: String) -> Observable<T?> {
        return Observable<T?>.create { observer -> Disposable in
            let requestReference = putInternal(url)
                    .responseJSON(completionHandler: { response in
                        if response.result.isSuccess {
                            let json = JSON(response.result.value)

                            if json[index].exists() {
                                let items = json[index].arrayValue
                                if !items.isEmpty {
                                    let casted = items[0].to(type: T.self) as? T
                                    observer.on(.next(casted))
                                } else {
                                    let casted = json[index].to(type: T.self) as? T
                                    observer.on(.next(casted))
                                }
                            } else {
                                observer.on(.next(nil))
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

    static func putNoResponse(_ url: String) -> Observable<Any?> {
        return Observable<Any?>.create { observer -> Disposable in
            let requestReference = putInternal(url).response { response in
                if response.error == nil {
                    observer.onNext(nil)
                    observer.onCompleted()
                } else {
                    observer.onError(response.error!)
                }
            }

            return Disposables.create {
                requestReference.cancel()
            }
        }
    }

    static func putBody(_ url: String, json body: String) -> Observable<JSON> {
        return Observable<JSON>.create { observer -> Disposable in
            let fullUrl = "\(Endpoint.apiUrl)\(url)"
            var request = URLRequest(url: URL(string: fullUrl)!)

            request.httpMethod = HTTPMethod.put.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let data = body.data(using: .utf8)
            request.httpBody = data

            Log.debug("POST: \(fullUrl)")

            let headers = getHeaders(fullUrl)
            request.allHTTPHeaderFields = headers

            let requestReference = Alamofire.request(request).responseJSON { response in
                if response.result.isSuccess {
                    let json = JSON(response.result.value)
                    observer.onNext(json)
                    observer.onCompleted()
                } else {
                    observer.onError(response.result.error!)
                }
            }

            return Disposables.create {
                requestReference.cancel()
            }
        }
    }
}
