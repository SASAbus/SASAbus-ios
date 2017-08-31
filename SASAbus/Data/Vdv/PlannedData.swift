import Foundation

import Alamofire
import SSZipArchive

import RxSwift
import RxCocoa

class PlannedData {

    static let FILENAME_ONLINE = "assets/archives/data"
    static let FILENAME_OFFLINE: String = "data.zip"

    static let PREF_UPDATE_AVAILABLE = "pref_data_update_available"
    static let PREF_DATA_DATE = "pref_data_date"

    private static var dataExists: Bool?

    public static func planDataExists() -> Bool {
        if dataExists == nil {
            let url = IOUtils.dataDir()

            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: url.path)

                if files.isEmpty {
                    Log.error("Planned data folder does not exist or is empty")
                    dataExists = false
                    return false
                }

                let hasMainFile = files.contains {
                    $0 == "planned_data.json"
                }

                if !hasMainFile {
                    Log.error("Main data file 'planned_data.json' is missing")
                    dataExists = false
                    return false
                }

                for file in files {
                    Log.info("Found data file '\(file)'")

                    if file.hasPrefix("trips_") {
                        dataExists = true
                        return true
                    }
                }

                Log.error("Planned data (JSON file) is missing")
                dataExists = false
            } catch let error {
                Utils.logError(error, message: "Cannot list contents of data directory, re-downloading: \(error)")
                dataExists = false
            }
        }

        return dataExists!
    }


    static func downloadFile(downloadUrl: URL) -> Observable<Float> {
        return Observable.create { observer in
            Log.debug("Downloading planned data to \(downloadUrl)")

            let fileManager = FileManager.default

            // Delete old files
            let dataDirectory = IOUtils.dataDir()
            if fileManager.fileExists(atPath: dataDirectory.path) {
                do {
                    try fileManager.removeItem(at: dataDirectory)
                    Log.warning("Deleted old data directory")
                } catch let error {
                    Utils.logError(error, message: "Could not delete old data directory: \(error)")
                }
            }

            if fileManager.fileExists(atPath: downloadUrl.path) {
                do {
                    try fileManager.removeItem(at: downloadUrl)
                    Log.warning("Deleted old data.zip")
                } catch let error {
                    Utils.logError(error, message: "Could not delete data.zip: \(error)")
                }
            }

            // Download new planned data
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (downloadUrl, [.removePreviousFile, .createIntermediateDirectories])
            }

            let progress: Alamofire.Request.ProgressHandler = { progress in
                observer.on(.next(Float(progress.fractionCompleted)))
            }

            let zipUrl = Endpoint.apiUrl.appending(FILENAME_ONLINE)
            Log.info("Zip url is '\(zipUrl)'")

            // Download new data
            let request = Alamofire.download(zipUrl, to: destination)
                    .downloadProgress(queue: DispatchQueue.main, closure: progress)
                    .response(queue: DispatchQueue(label: "com.sasabus.download", qos: .utility, attributes: [.concurrent])) { response in
                        if let error = response.error {
                            observer.on(.error(error))
                            return
                        }

                        do {
                            Log.info("Unzipping zip file '\(downloadUrl)'")

                            try IOUtils.unzipFile(from: downloadUrl, to: IOUtils.dataDir())

                            let fileManager = FileManager.default
                            try fileManager.removeItem(atPath: downloadUrl.path)
                        } catch {
                            observer.on(.error(error))
                            return
                        }

                        dataExists = true
                        setUpdateAvailable(false)
                        setDataDate()

                        do {
                            try VdvHandler.loadBlocking(observer)
                        } catch {
                            observer.on(.error(error))
                            return
                        }

                        observer.on(.completed)
                    }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    static func downloadPlanData() -> Observable<Float> {
        Log.warning("Starting plan data download")

        let baseUrl = IOUtils.storageDir()
        let downloadUrl = baseUrl.appendingPathComponent(FILENAME_OFFLINE)

        return downloadFile(downloadUrl: downloadUrl)
    }
}

extension PlannedData {

    static func setUpdateAvailable(_ newValue: Bool) {
        Log.info("Updating plan data update available flag to '\(newValue)'")
        UserDefaults.standard.set(newValue, forKey: PREF_UPDATE_AVAILABLE)
    }

    static func isUpdateAvailable() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_UPDATE_AVAILABLE)
    }

    static func setDataDate() {
        let time = Date().seconds()

        UserDefaults.standard.set(time, forKey: PREF_DATA_DATE)
    }

    static func getDataDate() -> Int {
        return UserDefaults.standard.integer(forKey: PREF_DATA_DATE)
    }
}
