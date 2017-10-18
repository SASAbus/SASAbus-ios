import Foundation

class ApiTime {
    
    static func addOffset(millis: Int64) -> Int64 {
        let offset = NSTimeZone(name: "Europe/Rome")!.secondsFromGMT * 1000
        return millis + Int64(offset)
    }
    
    static func now() -> Int64 {
        let now = Date().millis()
        return now + Int64(NSTimeZone(name: "Europe/Rome")!.daylightSavingTimeOffset)
    }
    
    static func toTime(seconds: Int) -> String {
        return String(format: "%02d:%02d", seconds / 3600 % 24, seconds % 3600 / 60)
    }
}
