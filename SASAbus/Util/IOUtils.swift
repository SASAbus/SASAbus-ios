import Foundation
import SSZipArchive
import SwiftyJSON

class IOUtils {

    static func readFileAsString(path: URL) -> String? {
        do {
            return try String(contentsOf: path)
        } catch let error {
            Log.error("Could not read fle \(path.path): \(error)")
        }

        return nil
    }

    static func readFileAsJson(path: URL) -> JSON? {
        if let json = readFileAsString(path: path) {
            return JSON.parse(json)
        }

        return nil
    }

    static func unzipFile(from: URL, to: URL) throws {
        let success = SSZipArchive.unzipFile(atPath: from.path, toDestination: to.path)
        if success {
            Log.warning("Unzipped timetables")
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
