import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON
import Firebase
import ObjectMapper

class ReportApi {

    static func upload(_ body: Body, images: [URL]) -> Observable<Any> {
        return Observable<Any>.create { observer -> Disposable in
            let url = "\(Endpoint.reportsApiUrl)\(Endpoint.REPORT)"

            let headers = RestClient.getHeaders(url)

            let converted = body.toJSONString()

            guard let json = converted else {
                Log.error("Cannot convert JSON")
                return Disposables.create()
            }

            Log.debug("POST: \(url)")

            Alamofire.upload(
                    multipartFormData: { formData in
                        formData.append(json.data(using: .utf8)!, withName: "body")

                        for i in 0..<images.count {
                            formData.append(
                                    images[i],
                                    withName: "image_\(i)",
                                    fileName: images[i].lastPathComponent,
                                    mimeType: "image/jpg"
                            )
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
                                        print("Upload Progress: \(progress.fractionCompleted)")
                                    }
                                    .downloadProgress { progress in
                                        print("Download Progress: \(progress.fractionCompleted)")
                                    }
                                    .response { response in
                                        debugPrint(response)

                                        if response.error == nil {
                                            observer.on(.next(""))
                                            observer.onCompleted()
                                        } else {
                                            observer.onError(response.error!)
                                        }
                                    }
                        case .failure(let error):
                            print(error)
                        }
                    })

            // TODO: Delete images after upload

            return Disposables.create()
        }
    }
}

class Body: Mappable {

    var name: String
    var email: String
    var message: String

    var category: Int

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

    internal var preferences: [String : String] = UserDefaults.standard.dictionaryRepresentation().map { (key, value) in
        (key, String(describing: value))
    }

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


    required init?(map: Map) {
        fatalError("Cannot be initialized from JSON")
    }

    func mapping(map: Map) {
        name <- map["name"]
        email <- map["email"]
        message <- map["message"]

        category <- map["category"]

        iosVersionCode <- map["iosVersionCode"]

        deviceName <- map["deviceName"]
        deviceModel <- map["deviceModel"]

        deviceIdentifier <- map["deviceIdentifier"]

        locale <- map["locale"]

        appVersionCode <- map["appVersionCode"]
        appVersionName <- map["appVersionName"]

        firebaseLastFetchTimeMillis <- map["firebaseLastFetchTimeMillis"]
        firebaseLastFetchTimeString <- map["firebaseLastFetchTimeString"]

        firebaseLastFetchStatus <- map["firebaseLastFetchStatus"]

        reportCreatedTimeMillis <- map["reportCreatedTimeMillis"]
        reportCreatedTimeString <- map["reportCreatedTimeString"]

        preferences <- map["preferences"]

        firebase <- map["firebase"]
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
