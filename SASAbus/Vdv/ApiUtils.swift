import Foundation

class ApiUtils {
    
    static func getTime(seconds: Int) -> String {
        return String(format: "%02d:%02d", seconds / 3600 % 24, seconds % 3600 / 60)
    }
    
    static func getSeconds(time: String) -> Int {
        let array = time.characters.split {$0 == ":"}.map(String.init)
        
        return Int(array[0])! * 3600 + Int(array[1])! * 60
    }
    
    static func implode(separator: String, data: [String], fallback: String) -> String {
        var sb: String = ""
    
        if data.count == 0 {
            return fallback
        }
    
        for i in 0..<data.count {
            sb += data[i]
            sb += separator
        }
    
        sb += data.last!
        
        return sb
    }
}
