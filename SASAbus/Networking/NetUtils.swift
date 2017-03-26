import Foundation
import UIKit
import SystemConfiguration
import SwiftyJSON

class NetUtils {

    static func getFileContent(url: String, callback: @escaping (Result<JSON, String>) -> ()) -> Void {
        let websiteUrl: String = Endpoint.API + url
        let websiteEndpoint = NSURL(string: websiteUrl)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let request = NSMutableURLRequest(url: websiteEndpoint as! URL)
        
        // Headers
        let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let versionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        
        request.setValue("SasaBus/\(versionName) iOS", forHTTPHeaderField: "User-Agent")
        request.setValue(DeviceUtils.getModel(), forHTTPHeaderField: "X-Device")
        request.setValue(Utils.locale(), forHTTPHeaderField: "X-Language")
        request.setValue(versionCode, forHTTPHeaderField: "X-Version-Code")
        request.setValue(versionName, forHTTPHeaderField: "X-Version-Name")
        
        print("GET \(websiteUrl)")
        
        let dataTask = session.dataTask(with: request as URLRequest) {( data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                    case 200:
                        let json = JSON(data: data!)
                        callback(Result.Success(json))
                    default:
                        callback(Result.Failure("HTTP status code: \(httpResponse.statusCode)"))
                }
            } else {
                callback(Result.Failure("Error: Not a valid HTTP response"))
            }
        }
        
        dataTask.resume()
    }
    
    static func isOnline() -> Bool {
        /*var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, UnsafePointer($0))
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired
        
        return isReachable && !needsConnection*/
        
        return true
    }
}

enum Result<U, T> {
    case Success(U)
    case Failure(T)
}
