import Foundation

import Alamofire
import SwiftyJSON
import Firebase
import ObjectMapper
import Permission

import RxSwift
import RxCocoa

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
                            Log.debug("Appending image 'image_\(i)'")
                            
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
                            Log.warning("SUCCESS")

                            request.request
                                    .uploadProgress { progress in
                                        Log.debug("Upload Progress: \(progress.fractionCompleted)")
                                    }
                                    .downloadProgress { progress in
                                        Log.debug("Download Progress: \(progress.fractionCompleted)")
                                    }
                                    .response { response in
                                        debugPrint(response)

                                        if response.error == nil {
                                            observer.on(.next(""))
                                            observer.onCompleted()
                                        } else {
                                            Utils.logError(response.error!, message: "Cannot send report")
                                        }
                                    }
                        case .failure(let error):
                            Utils.logError(error, message: "Cannot send report")
                        }
                    })

            return Disposables.create()
        }
    }
}

class Body: Mappable {

    var name: String
    var email: String
    var message: String

    var category: Int

    var iosVersion = UIDevice.current.systemVersion

    var deviceName = UIDevice.current.name
    var deviceModel = DeviceUtils.getModel()

    var deviceIdentifier = DeviceUtils.getIdentifier()

    var locale = Utils.locale()

    var appVersionCode = Bundle.main.versionCode
    var appVersionName = Bundle.main.versionName

    var locationPermissionAlways = Permission.locationAlways.status.description
    var locationPermissionWhenInUse = Permission.locationWhenInUse.status.description
    
    var notificationPermission = Permission.notifications.status.description

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

        iosVersion <- map["iosVersion"]

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
        
        locationPermissionAlways <- map["locationPermissionAlways"]
        locationPermissionWhenInUse <- map["locationPermissionWhenInUse"]
        
        notificationPermission <- map["notificationPermission"]

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
