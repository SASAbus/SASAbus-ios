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
        let success = try SSZipArchive.unzipFileAtPath(
                from.path, toDestination: to.path, overwrite: false, password: nil, delegate: nil
        )

        if success {
            Log.warning("Unzipped file \(from) to \(to)")
        } else {
            Log.error("Could not unzip files: No error thrown")
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
