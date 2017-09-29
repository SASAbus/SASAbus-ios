import Foundation
import SwiftyJSON

class IOUtils {

    static func readFileAsString(path: URL) throws -> String {
        return try String(contentsOf: path)
    }

    static func readFileAsJson(path: URL) throws -> JSON {
        let json = try readFileAsString(path: path)
        return JSON(parseJSON: json)
    }

    static func storageDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func dataDir() -> URL {
        return storageDir().appendingPathComponent("data/")
    }

    static func timetablesDir() -> URL {
        return storageDir().appendingPathComponent("timetables/")
    }
}
