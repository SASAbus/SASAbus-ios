import Foundation
import SSZipArchive
import SwiftyJSON

class IOUtils {

    static func readFileAsString(path: URL) throws -> String {
        return try String(contentsOf: path)
    }

    static func readFileAsJson(path: URL) throws -> JSON {
        let json = try readFileAsString(path: path)
        return JSON(parseJSON: json)
    }

    static func unzipFile(from: URL, to: URL) throws {
        let success = SSZipArchive.unzipFile(atPath: from.path, toDestination: to.path)
        if success {
            Log.warning("Unzipped file \(from) to \(to)")
        } else {
            Log.error("Could not unzip files")
            throw NSError(domain: "com.davale.sasabus", code: -1, userInfo: nil)
        }

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
