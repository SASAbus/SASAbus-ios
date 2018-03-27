import Foundation

extension Bundle {
    
    var versionName: String {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unavailable"
    }
    
    var versionCode: String {
        return self.infoDictionary?["CFBundleVersion"] as? String ?? "Unavailable"
    }
}
