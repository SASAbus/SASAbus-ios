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

class MapTilesDownloader: DownloaderProtocol {

    var description: String = NSLocalizedString("Map Download", comment: "")
    var request: Alamofire.Request?
    var lastProgress: Int = 0

    var alamoFireManager: SessionManager?

    func startDownload(_ circularProgress: ProgressIndicatorProtocol!) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = Config.downloadTimeoutIntervalForResource // seconds
        configuration.timeoutIntervalForRequest = Config.downloadTimeoutIntervalForRequest

        self.alamoFireManager = SessionManager(configuration: configuration)

        self.lastProgress = 0
        circularProgress.started(self.description)

        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var filename = String()

        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, response in
            filename = response.suggestedFilename!
            let url = directoryURL.appendingPathComponent(filename)
            return (url, [.createIntermediateDirectories, .removePreviousFile])
        }

        self.request = self.alamoFireManager!.download(Config.MAP_URL, to: destination)
                .downloadProgress { progress in
                    Log.info("Download progress: \(progress.fractionCompleted)")

                    circularProgress.progress(Int(Double(progress.fractionCompleted) * Double(100.0)), description: nil)
                }
                .responseData { response in
                    if response.result.isSuccess {
                        self.extract(circularProgress, directory: directoryURL, file: filename)
                    } else {
                        print(response.error!)
                        circularProgress.error(response.error?.localizedDescription, fatal: false)
                    }
                }
    }

    func stopDownload() {
        if self.request != nil {
            self.request?.cancel()
        }
    }

    func extract(_ circularProgress: ProgressIndicatorProtocol!, directory: URL, file: String) {
        Log.info("Extracting offline map")

        let url = directory.appendingPathComponent(file)

        let fileManager = FileManager.default

        do {
            circularProgress.reset(NSLocalizedString("Extracting File", comment: ""))
            self.lastProgress = 0

            circularProgress.progress(0, description: NSLocalizedString("Extracting ...", comment: ""))

            let archive = try ZZArchive(url: url)
            var fileCount = 0
            let totalFiles = archive.entries.count

            for entry: ZZArchiveEntry in archive.entries {
                fileCount += 1

                let targetPath: URL = directory.appendingPathComponent(Config.MAP_FOLDER + entry.fileName)

                if entry.fileMode & S_IFDIR != 0 {
                    Log.info("Creating directory \(targetPath.absoluteString)")

                    try fileManager.createDirectory(at: targetPath, withIntermediateDirectories: true)
                } else {
                    Log.info("Extracting file \(targetPath.absoluteString)")
                    try entry.newData().write(to: targetPath)
                }

                let progress = Int((100 * fileCount) / totalFiles)
                if progress > self.lastProgress {
                    self.lastProgress = progress
                    circularProgress.progress(progress, description: nil)
                }
            }

            UserDefaultHelper.instance.setMapDownloadStatus(true)
            circularProgress.finished()

            //delete file
            try fileManager.removeItem(at: url)
        } catch {
            print(error)
            circularProgress.error(error.localizedDescription, fatal: false)
        }
    }
}
