
import Foundation

import RxSwift
import RxCocoa

import Alamofire


class DataDownloader {

    static let FILENAME_OFFLINE = "data.zip"
    
    
    static func downloadFile(destinationUrl: URL) -> Observable<Float> {
        return Observable.create { observer in
            Log.debug("Downloading planned data to \(destinationUrl)")
            
            let fileManager = FileManager.default
            
            // Delete old files
            let dataDirectory = IOUtils.dataDir()
            if fileManager.fileExists(atPath: dataDirectory.path) {
                do {
                    try fileManager.removeItem(at: dataDirectory)
                    Log.warning("Deleted old data directory")
                } catch let error {
                    ErrorHelper.log(error, message: "Could not delete old data directory: \(error)")
                }
            }
            
            if fileManager.fileExists(atPath: destinationUrl.path) {
                do {
                    try fileManager.removeItem(at: destinationUrl)
                    Log.warning("Deleted old data.zip")
                } catch let error {
                    ErrorHelper.log(error, message: "Could not delete data.zip: \(error)")
                }
            }
            
            // Download new planned data
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (destinationUrl, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            let progress: Alamofire.Request.ProgressHandler = { progress in
                observer.on(.next(Float(progress.fractionCompleted)))
            }
            
            let zipUrl = Endpoint.newDataApiUrl
            Log.info("Data url is '\(zipUrl)'")
            
            // Download new data
            let request = Alamofire.download(zipUrl, to: destination)
                .downloadProgress(queue: DispatchQueue.main, closure: progress)
                .response(queue: DispatchQueue(label: "com.sasabus.download", qos: .utility, attributes: [.concurrent])) { response in
                    if let error = response.error {
                        observer.on(.error(error))
                        return
                    }
                    
                    do {
                        Log.info("Unzipping zip file '\(destination)'")
                        
                        try ZipUtils.unzipFile(from: destinationUrl, to: IOUtils.dataDir())
                        
                        let fileManager = FileManager.default
                        try fileManager.removeItem(atPath: destinationUrl.path)
                    } catch {
                        observer.on(.error(error))
                        return
                    }
                    
                    PlannedData.dataExists = true
                    PlannedData.setUpdateAvailable(false)
                    PlannedData.setDataDate()
                    
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
        let destinationUrl = baseUrl.appendingPathComponent(FILENAME_OFFLINE)
        
        return downloadFile(destinationUrl: destinationUrl)
    }
}
