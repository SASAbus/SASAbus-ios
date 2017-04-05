import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SSZipArchive

class PlannedData {

    static let FILENAME_ONLINE = "assets/archives/planned-data"
    static let FILENAME_OFFLINE: String = "data.zip"

    static let PREF_UPDATE_AVAILABLE = "pref_data_update_available"
    static let PREF_DATA_DATE = "pref_data_date"

    private static var dataExists: Bool?

    public static func planDataExists() -> Bool {
        if dataExists == nil {
            let url = IOUtils.dataDir().appendingPathComponent("planned-data.json")

            Log.trace(url)

            if FileManager.default.fileExists(atPath: url.path) {
                dataExists = true
            } else {
                Log.error("Planned data (JSON file) is missing")
                dataExists = false
            }
        }

        return dataExists!
    }


    static func downloadFile(downloadUrl: URL) -> Observable<Float> {
        return Observable.create { observer in
            // Delete old data.zip

            Log.debug("Downloading planned data to \(downloadUrl)")

            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: downloadUrl.path) {
                do {
                    try fileManager.removeItem(at: downloadUrl)
                    Log.warning("Deleted old data.zip")
                } catch let error {
                    Log.error("Could not delete data.zip: \(error)")
                }
            }

            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (downloadUrl, [.removePreviousFile, .createIntermediateDirectories])
            }

            let progress: Alamofire.Request.ProgressHandler = { progress in
                observer.on(.next(Float(progress.fractionCompleted)))
            }

            // Download new data
            let request = Alamofire.download(Endpoint.API.appending(FILENAME_ONLINE), to: destination)
                    .downloadProgress(queue: DispatchQueue.main, closure: progress)
                    .response(queue: DispatchQueue(label: "com.sasabus.download", qos: .utility, attributes: [.concurrent])) { response in
                        if let error = response.error {
                            observer.on(.error(error))
                        } else {
                            Log.info("Unzipping plan data")

                            do {
                                try unzipData(downloadUrl: downloadUrl)
                            } catch {
                                observer.on(.error(error))
                                return
                            }

                            dataExists = true
                            setUpdateAvailable(false)
                            setDataDate()

                            _ = VdvHandler.load().subscribe()

                            observer.on(.completed)
                        }
                    }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    static func unzipData(downloadUrl: URL) throws {
        let finalUrl: URL = IOUtils.dataDir()
        try IOUtils.unzipFile(from: downloadUrl, to: finalUrl)

        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: downloadUrl.path)
    }

    static func downloadPlanData() -> Observable<Float> {
        Log.warning("Starting plan data download")

        let baseUrl = IOUtils.storageDir()
        let downloadUrl = baseUrl.appendingPathComponent(FILENAME_OFFLINE)

        return downloadFile(downloadUrl: downloadUrl)
    }


    // - MARK: Settings

    static func setUpdateAvailable(_ newValue: Bool) {
        Log.info("Updating plan data update available flag to '%s'", newValue)
        UserDefaults.standard.set(newValue, forKey: PREF_UPDATE_AVAILABLE)
    }

    static func isUpdateAvailable() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_UPDATE_AVAILABLE)
    }

    /**
     * Sets the date when the plan data has been downloaded.
     *
     * @param context Context to be used to edit the [SharedPreferences].
     */
    private static func setDataDate() {
        var format = DateFormatter()
        format.dateFormat = "yyyMMdd"

        UserDefaults.standard.set(format.string(from: Date()), forKey: PREF_DATA_DATE)
    }

    /**
     * Returns the date when the plan data has been downloaded. This is done to check if there are
     * new plan data updates available depending on when the user downloaded it last.
     *
     * @param context Context to be used to access the [SharedPreferences].
     * @return a String with the date in form `YYYYMMDD`. Defaults to 19700101.
     */
    static func getDataDate() -> String {
        return UserDefaults.standard.string(forKey: PREF_DATA_DATE) ?? "19700101"
    }
}
