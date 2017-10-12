import Foundation

class Errors {
    
    public static func json() -> Error {
        return NSError(domain: "it.sasabz.ios.SASAbus", code: 2000, userInfo: [:])
    }
    
    public static func network() -> Error {
        return NSError(domain: "it.sasabz.ios.SASAbus", code: 2001, userInfo: [:])
    }
    
    public static func withMessage(message: String) -> Error {
        return NSError(domain: "it.sasabz.ios.SASAbus", code: 2001, userInfo: ["message": message])
    }
}
