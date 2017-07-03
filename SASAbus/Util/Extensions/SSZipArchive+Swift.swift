import Foundation
import SSZipArchive

extension SSZipArchive {

    static func unzipFileAtPath(_ path: String, toDestination destination: String, overwrite: Bool,
                                password: String?, delegate: SSZipArchiveDelegate?) throws -> Bool {

        var success = false
        var error: NSError?

        success = __unzipFile(atPath: path, toDestination: destination, overwrite: overwrite, password: password, error: &error, delegate: delegate)
        if let throwableError = error {
            throw throwableError
        }

        return success
    }
}