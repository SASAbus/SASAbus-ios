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

class SasaBusDownloader: DownloaderProtocol {

    var params: [String] = [
            "REC_LID",
            "LID_VERLAUF",
            "REC_ORT",
            "FIRMENKALENDER",
            "SEL_FZT_FELD",
            "REC_FRT_FZT",
            "REC_FRT_HZT",
            "ORT_HZT",
            "REC_LIVAR_HZT"
    ]

    var downloadCount: Int = 0
    var description: String = NSLocalizedString("Initializing Data", comment: "")
    var request: Alamofire.Request?
    var errorOccured: Bool?
    var errorDescription: String?
    var alamoFireManager: SessionManager?

    func startDownload(_ progressIndicator: ProgressIndicatorProtocol!) {
        let configuration = URLSessionConfiguration.default

        configuration.timeoutIntervalForResource = Config.downloadTimeoutIntervalForResource // seconds
        configuration.timeoutIntervalForRequest = Config.downloadTimeoutIntervalForRequest

        self.alamoFireManager = SessionManager(configuration: configuration)

        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = directoryURL.appendingPathComponent(Config.PLANNED_DATA_FOLDER)

        self.createFolderIfNotExistent(destinationURL.description)

        self.downloadCount = 0
        self.errorOccured = false
        self.errorDescription = nil

        progressIndicator.started(self.description)

        let asyncGroup = DispatchGroup()

        for param in params {
            asyncGroup.enter()
            self.downloadFile(param, to: destinationURL, progressIndicator: progressIndicator, group: asyncGroup)
        }

        asyncGroup.notify(queue: .main) {
            if self.errorOccured == true {
                progressIndicator.error(self.errorDescription, fatal: true)
            } else {
                // Prepare data for download step 2
                self.downloadCount = 0

                let calendar = SasaDataHelper.getData(SasaDataHelper.FIRMENKALENDER) as [BusDayTypeItem]

                var uniqueDayTypes = [Int]()

                for busDayType in calendar {
                    if !uniqueDayTypes.contains(busDayType.dayTypeNumber) {
                        uniqueDayTypes.append(busDayType.dayTypeNumber)
                    }
                }

                uniqueDayTypes.sort()

                let busLineList: [Line] = SasaDataHelper.getData(SasaDataHelper.REC_LID) as [Line]

                var uniqueBusLines = [Int]()
                for busLine in busLineList {
                    if !uniqueBusLines.contains(busLine.id) {
                        uniqueBusLines.append(busLine.id)
                    }
                }

                uniqueBusLines.sort()

                self.params.removeAll()

                for uniqueBusLine in uniqueBusLines {
                    for uniqueDayType in uniqueDayTypes {
                        self.params.append("REC_FRT&LI_NR=\(uniqueBusLine)&TAGESART_NR=\(uniqueDayType)")
                    }
                }

                self.params.append("BASIS_VER_GUELTIGKEIT")

                for param in self.params {
                    asyncGroup.enter()
                    self.downloadFile(param, to: destinationURL, progressIndicator: progressIndicator, group: asyncGroup)
                }

                asyncGroup.notify(queue: .main) {
                    if self.errorOccured == true {
                        progressIndicator.error(self.errorDescription, fatal: true)
                    } else {
                        UserDefaultHelper.instance.setDataDownloadStatus(true)
                        progressIndicator.finished()
                    }
                }
            }
        }
    }

    func stopDownload() {
        if self.request != nil {
            self.request?.cancel()
        }
    }

    func downloadFile(_ param: String, to: URL, progressIndicator: ProgressIndicatorProtocol, group: DispatchGroup) {
        var file = param.replacingOccurrences(of: "&", with: "_")

        file = file.replacingOccurrences(of: "=", with: "_")

        let downloadUrl = Config.PLANNED_DATA_URL + "?type=" + param
        let destinationUrl = to.appendingPathComponent(file)

        Log.debug("Downloading file \(param) from \(downloadUrl) to \(destinationUrl)")

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationUrl, [.removePreviousFile, .createIntermediateDirectories])
        }

        alamoFireManager!.download(downloadUrl, to: destination).responseData { response in
            if response.result.isSuccess {
                Log.info("Downloaded \(response.request!.url!.absoluteString)")

                self.enrichData(file, destinationUrl: destinationUrl)
                self.incrementProgress(progressIndicator)
            } else {
                print(response.error!)

                self.errorOccured = true
                self.errorDescription = response.error?.localizedDescription
            }

            group.leave()
        }
    }

    func calculateBusLinesOfBusStation() -> String {
        let busStationList: [BusStationItem] = SasaDataHelper.getData(SasaDataHelper.REC_ORT) as [BusStationItem]
        let busPathList: [BusPathItem] = SasaDataHelper.getData(SasaDataHelper.LID_VERLAUF) as [BusPathItem]

        for busPathItem in busPathList {
            for busPathVariant in busPathItem.variants {
                for busStopId in busPathVariant.busStops {
                    busStationLoop: for busStation in busStationList {
                        for busStationStop in busStation.busStops {
                            if busStationStop.number == busStopId {
                                busStation.addBusLineId(busPathItem.lineNumber)
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
            let theJSONData = try JSONSerialization.data(
                    withJSONObject: busStationDictionaries,
                    options: JSONSerialization.WritingOptions(rawValue: 0))
            json = String(data: theJSONData, encoding: String.Encoding.utf8)!
        } catch {
            Log.error(error)
        }

        return json
    }

    func incrementProgress(_ progressIndicator: ProgressIndicatorProtocol) {
        self.downloadCount += 1
        var base: Int = 100

        if self.downloadCount <= 9 {
            base = 9
        }

        let progress = Int((base * self.downloadCount) / self.params.count)
        progressIndicator.progress(progress, description: nil)
    }

    func enrichData(_ file: String, destinationUrl: URL) {
        if file == SasaDataHelper.REC_ORT {
            let newJson = self.calculateBusLinesOfBusStation()
            do {
                try newJson.write(to: destinationUrl, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                Log.error(error)
            }
        }
    }

    func createFolderIfNotExistent(_ path: String) {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                    FileManager.SearchPathDomainMask.userDomainMask, true)

            var documentsDirectory: String = paths[0]
            documentsDirectory.append(Config.PLANNED_DATA_FOLDER)

            if !FileManager.default.fileExists(atPath: documentsDirectory) {
                try FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: false)
            }
        } catch {
            print(error)
        }
    }
}
