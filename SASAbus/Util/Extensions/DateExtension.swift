import Foundation

extension Date {
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }

    func millis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }

    func seconds() -> Int {
        return Int(timeIntervalSince1970)
    }
}

extension Formatter {
    
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Foundation.Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
