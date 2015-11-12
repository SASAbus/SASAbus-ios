//
// SasaBusDownloader.swift
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

class SasaBusDownloader:DownloaderProtocol{
    
    var params:[String] = [
        "REC_LID",
        "LID_VERLAUF",
        "REC_ORT",
        "FIRMENKALENDER",
        "SEL_FZT_FELD",
        "REC_FRT_FZT",
        "REC_FRT_HZT",
        "ORT_HZT",
        "REC_LIVAR_HZT"]
    
    var downloadCount: Int = 0
    var description: String = NSLocalizedString("Initializing Data", comment: "")
    var request: Alamofire.Request?
    var errorOccured:Bool?
    var errorDescription:String?
    var alamoFireManager:Manager?
    
    func startDownload(progressIndicator:ProgressIndicatorProtocol!) {
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForResource = Configuration.downloadTimeoutIntervalForResource // seconds
        configuration.timeoutIntervalForRequest = Configuration.downloadTimeoutIntervalForRequest
        self.alamoFireManager = Alamofire.Manager(configuration: configuration)
        
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let destinationURL = directoryURL.URLByAppendingPathComponent(Configuration.dataFolder)
        
        self.createFolderIfNotExistent(destinationURL.description)

        //download all files -- Atention it is recursive
        let dispatchGroupBaseFiles: dispatch_group_t = dispatch_group_create()
        
        self.downloadCount = 0
        self.errorOccured = false
        self.errorDescription = nil
        progressIndicator.started(self.description)
        for param in params {
            dispatch_group_enter(dispatchGroupBaseFiles)
            self.downloadFile(param, to: destinationURL, progressIndicator: progressIndicator, group:dispatchGroupBaseFiles)
        }
        
        dispatch_group_notify(dispatchGroupBaseFiles, dispatch_get_main_queue(), {
            
            if self.errorOccured == true {
                progressIndicator.error(self.errorDescription,fatal:true)
            } else {
                //prepare data for download step 2
                self.downloadCount = 0
                let busDayTypeList: [BusDayTypeItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusDayTypeList) as [BusDayTypeItem]
                
                var uniqueDayTypes = [Int]()
                for busDayType in busDayTypeList {
                    if !uniqueDayTypes.contains(busDayType.getDayTypeNumber()) {
                        uniqueDayTypes.append(busDayType.getDayTypeNumber())
                    }
                }
                uniqueDayTypes.sortInPlace()
                
                let busLineList: [BusLineItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusLines) as [BusLineItem]
                
                var uniqueBusLines = [Int]()
                for busLine in busLineList {
                    if !uniqueBusLines.contains(busLine.getNumber()) {
                        uniqueBusLines.append(busLine.getNumber())
                    }
                }
                uniqueBusLines.sortInPlace()
                let dispatchGroupDayType: dispatch_group_t = dispatch_group_create()
                
                self.params.removeAll()
                for uniqueBusLine in uniqueBusLines {
                    for uniqueDayType in uniqueDayTypes {
                        
                        self.params.append("REC_FRT&LI_NR=\(uniqueBusLine)&TAGESART_NR=\(uniqueDayType)")
                    }
                }
                self.params.append("BASIS_VER_GUELTIGKEIT")
                
                for param in self.params {
                    dispatch_group_enter(dispatchGroupDayType)
                    self.downloadFile(param, to: destinationURL, progressIndicator: progressIndicator, group: dispatchGroupDayType)
                }
                
                dispatch_group_notify(dispatchGroupDayType, dispatch_get_main_queue(), {
                    if self.errorOccured == true {
                        progressIndicator.error(self.errorDescription, fatal:true)
                    } else {
                        UserDefaultHelper.instance.setDataDownloadStatus(true)
                        progressIndicator.finished()
                    }
                })
            }
            
        })
    }
    
    private func precalculateBusLinesOfBusStation() -> String {
        let busStationList: [BusStationItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]
        let busPathList: [BusPathItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusPathList) as [BusPathItem]
        
        for busPathItem in busPathList {
            for busPathVariant in busPathItem.getVariants() {
                 for busStopId in busPathVariant.getBusStops() {
                busStationLoop:    for busStation in busStationList {
                        for busStationStop in busStation.getBusStops() {
                            if busStationStop.getNumber() == busStopId {
                                busStation.addBusLineId(busPathItem.getLineNumber())
                                break busStationLoop
                            }
                        }
                    }
                }
            }
        }
        
        var busStationDictionaries = [Dictionary<String, AnyObject>]()
        for busStation in busStationList {
            busStationDictionaries.append(busStation.getDictionary())
        }
        
        var json = ""
        do {
            let theJSONData = try NSJSONSerialization.dataWithJSONObject(
                busStationDictionaries ,
                options: NSJSONWritingOptions(rawValue: 0))
            json = String(data: theJSONData, encoding: NSUTF8StringEncoding)!
        } catch {}
        return json
    }
    
    func stopDownload() {
        if self.request != nil {
            self.request?.cancel()
        }
    }
    
    func downloadFile(param:String, to:NSURL, progressIndicator:ProgressIndicatorProtocol, group: dispatch_group_t) {
        
        var file = param.stringByReplacingOccurrencesOfString("&", withString: "_")
        file = file.stringByReplacingOccurrencesOfString("=", withString: "_")
        let downloadUrl = Configuration.dataUrl + "?type=" + param
        let destinationUrl = to.URLByAppendingPathComponent(file)
        
        do {
            try NSFileManager.defaultManager().removeItemAtURL(destinationUrl)
        } catch {}
        
        alamoFireManager!.download(.GET, downloadUrl) { temporaryURL, response in
            return destinationUrl
        }
        .response { request, response, data, error  in
            if error != nil {
                self.errorOccured = true
                self.errorDescription = error?.localizedDescription
            } else {
                self.enrichData(file, destinationUrl: destinationUrl)
                self.someProgress(progressIndicator)
            }
            dispatch_group_leave(group)
        }
    }
    
    func someProgress(progressIndicator:ProgressIndicatorProtocol) {
        self.downloadCount++
        var base:Int = 100
        if self.downloadCount <= 9 {
            base = 9
        }
        let progress = Int((base *  self.downloadCount) / self.params.count )
        progressIndicator.progress(progress, description:nil)
    }
    
    func enrichData(file:String, destinationUrl:NSURL) {
        if file == SasaDataHelper.BusStations {
            let newJson = self.precalculateBusLinesOfBusStation()
            do {
                try newJson.writeToURL(destinationUrl, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {}
        }
    }
    
    func createFolderIfNotExistent(path:String) {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            let dataPath = documentsDirectory.stringByAppendingPathComponent(Configuration.dataFolder)
            
            if (!NSFileManager.defaultManager().fileExistsAtPath(dataPath)) {
                try NSFileManager.defaultManager() .createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
            }
        } catch let error as NSError{
            NSLog(error.localizedDescription)
        }
    }
}