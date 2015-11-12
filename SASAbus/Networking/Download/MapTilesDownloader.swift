//
// MapTilesDownloader.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import Alamofire
import zipzap

class MapTilesDownloader:DownloaderProtocol{

    var description: String = NSLocalizedString("Map Download", comment: "")
    var request: Alamofire.Request?
    var lastProgress: Int = 0
    var alamoFireManager:Manager?
    
    func startDownload(circularProgress:ProgressIndicatorProtocol!) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = Configuration.downloadTimeoutIntervalForResource // seconds
        configuration.timeoutIntervalForRequest = Configuration.downloadTimeoutIntervalForRequest
        self.alamoFireManager = Alamofire.Manager(configuration: configuration)

        
        self.lastProgress = 0
        circularProgress.started(self.description)
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        var filename = String()
        
        do {
            try fileManager.removeItemAtURL(directoryURL.URLByAppendingPathComponent("osm-tiles.zip"))
        } catch {}
        
        self.request = self.alamoFireManager!.download(.GET, Configuration.mapDownloadZip) { temporaryURL, response in
            filename =  response.suggestedFilename!
            let url = directoryURL.URLByAppendingPathComponent(filename)
            return url
        }
        .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
            let progress = Int((100 * totalBytesRead) / totalBytesExpectedToRead )
            if progress > self.lastProgress {
                self.lastProgress = progress;
                circularProgress.progress(progress, description:nil)
            }
        }
        .response { request, response, data, error  in
            
            if error != nil {
                circularProgress.error(error?.localizedDescription, fatal:false)
            } else {
                let url = directoryURL.URLByAppendingPathComponent(filename)
                let qualityOfServiceClass = QOS_CLASS_BACKGROUND
                let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
                dispatch_async(backgroundQueue, {
                    do {
                        circularProgress.reset(NSLocalizedString("Extracting File", comment: ""))
                        self.lastProgress = 0
                        circularProgress.progress(0, description:NSLocalizedString("Extracting ...", comment: ""))
                        let archive = try ZZArchive(URL: url)
                        var fileCount = 0
                        let totalFiles = archive.entries.count
                        for entry:ZZArchiveEntry in archive.entries as! [ZZArchiveEntry] {
                            fileCount++
                            let targetPath:NSURL = directoryURL.URLByAppendingPathComponent(Configuration.mapTilesDirectory + entry.fileName) as NSURL
                            if entry.fileMode & S_IFDIR != 0 {
                                try fileManager.createDirectoryAtURL(targetPath, withIntermediateDirectories: true, attributes: nil)
                            } else {
                                try fileManager.createDirectoryAtURL(targetPath.URLByDeletingLastPathComponent!, withIntermediateDirectories: true, attributes: nil)
                                try entry.newData().writeToURL(targetPath, atomically:true);
                            }
                            
                            let progress = Int((100 * fileCount) / totalFiles )
                            if progress > self.lastProgress {
                                self.lastProgress = progress;
                                circularProgress.progress(progress, description:nil)
                            }
                        }
                        
                        UserDefaultHelper.instance.setMapDownloadStatus(true)
                        circularProgress.finished()
                        
                        //delete file
                        try fileManager.removeItemAtURL(url)
                    } catch let error as NSError{
                        circularProgress.error(error.localizedDescription, fatal:false)
                    }
                })
            }
        }
    }
    
    func stopDownload() {
        if self.request != nil {
            self.request?.cancel()
        }
    }
}