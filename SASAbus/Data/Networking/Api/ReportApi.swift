import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON
import Firebase

class ReportApi {

    static func upload() -> Observable<Any> {
        return Observable<Any>.create { observer -> Disposable in
            let url = "\(Endpoint.reportsApiUrl)\(Endpoint.REPORT)"

            let headers = RestClient.getHeaders(url)

            let fileNames: [String] = []

            Log.debug("POST: \(url)")

            Alamofire.upload(
                    multipartFormData: { formData in
                        for i in 0..<fileNames.count {
                            let path = URL(fileURLWithPath: fileNames[i])
                            formData.append(path, withName: "image_\(i)")
                        }
                    },
                    to: url,
                    method: .post,
                    headers: headers,
                    encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let request):
                            print("SUCCESS")

                            request.request
                                    .uploadProgress { progress in
                                        // main queue by default
                                        print("Upload Progress: \(progress.fractionCompleted)")
                                    }
                                    .downloadProgress { progress in
                                        // main queue by default
                                        print("Download Progress: \(progress.fractionCompleted)")
                                    }
                                    .responseJSON { response in
                                        debugPrint(response)

                                        if response.result.isSuccess {
                                            observer.on(.next(""))
                                            observer.onCompleted()
                                        } else {
                                            observer.onError(response.result.error!)
                                        }
                                    }
                        case .failure(let error):
                            print(error)
                        }
                    })

            return Disposables.create()
        }
    }
}

class Body {

    let name: String
    let email: String
    let message: String

    let category: Int

    var iosVersionCode = UIDevice.current.systemVersion

    var deviceName = UIDevice.current.name
    var deviceModel = UIDevice.current.model

    var deviceIdentifier = DeviceUtils.getIdentifier()

    var locale = Utils.locale()

    var appVersionCode = Bundle.main.versionCode
    var appVersionName = Bundle.main.versionName

    // TODO: location permission

    internal var firebaseLastFetchTimeMillis: Int64
    internal var firebaseLastFetchTimeString: String

    internal var firebaseLastFetchStatus: Int

    internal var reportCreatedTimeMillis: Int64
    internal var reportCreatedTimeString: String

    internal var preferences: [String : Any] = UserDefaults.standard.dictionaryRepresentation()

    internal var firebase: [String : String]!


    init(name: String, email: String, message: String, category: Int) {
        self.name = name
        self.email = email
        self.message = message
        self.category = category

        let remoteConfig = RemoteConfig.remoteConfig()

        firebaseLastFetchTimeMillis = remoteConfig.lastFetchTime!.millis()
        firebaseLastFetchTimeString = remoteConfig.lastFetchTime!.iso8601

        firebaseLastFetchStatus = remoteConfig.lastFetchStatus.rawValue

        reportCreatedTimeMillis = Date().millis()
        reportCreatedTimeString = Date().iso8601

        firebase = parseFirebase()
    }

    func parseFirebase() -> [String : String] {
        var map = [String: String]()

        let remoteConfig = RemoteConfig.remoteConfig()

        for s in remoteConfig.keys(withPrefix: "") {
            let value = remoteConfig[s].stringValue
            map[s] = value
        }

        return map
    }
}