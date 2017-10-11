//
//  DataDownloader.swift
//  SASAbus
//
//  Created by Alex Lardschneider on 27/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import Alamofire


class DataDownloader {
    
    static let FILENAME_ONLINE = "assets/archives/data"
    static let FILENAME_OFFLINE = "data.zip"
    
    
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
                        
                        try ZipUtils.unzipFile(from: downloadUrl, to: IOUtils.dataDir())
                        
                        let fileManager = FileManager.default
                        try fileManager.removeItem(atPath: downloadUrl.path)
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
        let downloadUrl = baseUrl.appendingPathComponent(FILENAME_OFFLINE)
        
        return downloadFile(downloadUrl: downloadUrl)
    }
}
