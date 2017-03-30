import Foundation
import RxSwift
import RxCocoa
import Alamofire
import SSZipArchive

class PlanData {

    static let FILENAME_ONLINE = "assets/archives/vdv"
    static let FILENAME_OFFLINE: String = "data.zip"

    /**
     * All the plan data files we need.
     */
    static let FILES = [
        "FIRMENKALENDER",
        "LID_VERLAUF",
        "ORT_HZT",
        "REC_FRT",
        "REC_FRT_HZT",
        "SEL_FZT_FELD"
    ]

    static func planDataExists() -> Bool {
        let dataUrl = IOUtils.dataDir()
        let fileManager = FileManager.default

        for file in FILES {
            let filePath = dataUrl.appendingPathComponent("\(file).json")

            if !fileManager.fileExists(atPath: filePath.path) {
                Log.error("Missing file: \(file)")
                return false
            }
        }

        return true
    }

    static func downloadFile(downloadUrl: URL) -> Observable<Float> {
        return Observable.create { observer in
            // Delete old data.zip

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
                .response { response in
                    if let error = response.error {
                        observer.on(.error(error))
                    } else {
                        Log.info("Unzipping plan data")

                        do {
                            try unzipData(downloadUrl: downloadUrl)
                        } catch {
                            observer.on(.error(error))
                        }

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
}
