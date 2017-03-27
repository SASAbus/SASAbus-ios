//
// DownloadViewController.swift
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

import UIKit
import KDCircularProgress
import Alamofire
import SwiftyJSON

class DownloadViewController: UIViewController {

    @IBOutlet var downloadProgress: KDCircularProgress!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    let downloader: DownloaderProtocol!
    let downloadFinishedDelegate: DownloadFinishedProtocol!
    var canBeCanceled: Bool!
    var showFinishedDialog: Bool!
    var askForDownload: Bool!

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, downloader: DownloaderProtocol,
         downloadFinishedDelegate: DownloadFinishedProtocol!, canBeCanceled: Bool, showFinishedDialog: Bool? = true, askForDownload: Bool? = false) {

        self.downloader = downloader
        self.canBeCanceled = canBeCanceled
        self.showFinishedDialog = showFinishedDialog
        self.downloadFinishedDelegate = downloadFinishedDelegate
        self.askForDownload = askForDownload

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressLabel.text = ""
        self.view.backgroundColor = Theme.darkGrey
        self.downloadProgress.angle = 0
        self.downloadProgress.progressThickness = 0.04
        self.downloadProgress.trackThickness = 0.05
        self.downloadProgress.clockwise = true
        self.downloadProgress.center = view.center
        self.downloadProgress.gradientRotateSpeed = 100
        self.downloadProgress.roundedCorners = true
        self.downloadProgress.glowMode = .noGlow
        self.downloadProgress.trackColor = Theme.white
        self.downloadProgress.set(colors: Theme.orange, Theme.orange, Theme.orange)
        self.downloadProgress.isHidden = true
        self.titleLabel.isHidden = true
        self.progressLabel.isHidden = true
        self.cancelButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if (self.downloader is SasaBusDownloader) {
            Log.info("Downloading plan data")

            if UserDefaultHelper.instance.getDataDownloadStatus() == false {
                Log.info("Plan data does not exist")

                self.startDownload()
            } else {
                Log.info("Plan data does exist, checking expiration")

                Alamofire.request(SasaOpenDataApiRouter.getExpirationDate())
                        .responseJSON(completionHandler: { result in
                            if (result.result.isSuccess) {
                                do {
                                    let expirationItemServer = ExpirationItem(parameter: JSON(result.data))
                                    let expirationItemLocal: ExpirationItem = try SasaDataHelper.getData(SasaDataHelper.BASIS_VER_GUELTIGKEIT)! as ExpirationItem

                                    if Calendar.current.compare((expirationItemServer.expirationDate)!, to: expirationItemLocal.expirationDate, toGranularity: Calendar.Component.day) != ComparisonResult.orderedSame {
                                        self.startDownload()
                                    } else {
                                        self.cancelButtonDown(self)
                                    }
                                } catch {
                                    self.startDownload()
                                }
                            } else {
                                self.cancelButtonDown(self)
                            }
                        })
            }
        } else {
            if self.askForDownload == true {
                self.askForDownloadDialog()
            } else {
                self.startDownload()
            }
        }
    }


    func startDownload() {
        self.downloadProgress.isHidden = false
        self.titleLabel.isHidden = false
        self.progressLabel.isHidden = false
        self.cancelButton.isHidden = !self.canBeCanceled

        self.downloader.startDownload(DownloadViewProgressIndicator(downloadViewController: self))
    }

    // Refactor message hardcoded for map download
    func askForDownloadDialog() {
        let toDownloadAlert = UIAlertController(title: NSLocalizedString("Download", comment: ""), message: NSLocalizedString("Do you want to download the mapdata now?", comment: ""), preferredStyle: UIAlertControllerStyle.alert)

        toDownloadAlert.addAction(UIAlertAction(title: NSLocalizedString("No later", comment: ""), style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            UserDefaultHelper.instance.incrementAskedForDownloadsNoCount()
            self.cancelButtonDown(self)
        }))

        toDownloadAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.startDownload()
        }))

        if (UserDefaultHelper.instance.getAskedForDownloadsNoCount() >= Config.mapHowOftenShouldIAskForMapDownload) {
            toDownloadAlert.addAction(UIAlertAction(title: NSLocalizedString("Do not ask me again", comment: ""), style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in

                let mapDowloadReminderAlert = UIAlertController(title: NSLocalizedString("Info", comment: ""), message: NSLocalizedString("You can re enable map download in app settings", comment: ""), preferredStyle: UIAlertControllerStyle.alert)

                mapDowloadReminderAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in

                    UserDefaultHelper.instance.setAskForMapDownload(false)
                    self.cancelButtonDown(self)
                }))

                self.present(mapDowloadReminderAlert, animated: true, completion: nil)
            }))
        }

        self.present(toDownloadAlert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancelButtonDown(_ sender: AnyObject) {
        self.downloader.stopDownload()
        self.dismiss(animated: true, completion: nil)
        if self.downloadFinishedDelegate != nil {
            self.downloadFinishedDelegate.finished()
        }
    }

    func downloadFinished() {
        if self.showFinishedDialog == true {
            let downloadFinishedAlert = UIAlertController(title: NSLocalizedString("Download", comment: ""), message: NSLocalizedString("Download finished successfully", comment: ""), preferredStyle: UIAlertControllerStyle.alert)

            downloadFinishedAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
                self.propagateDelegate()

            }))
            self.present(downloadFinishedAlert, animated: true, completion: nil)
        } else {
            self.propagateDelegate()
        }
    }

    func downloadFinishedWithError(_ errorMessage: String, killApp: Bool) {

        var message = errorMessage
        if killApp == true {
            message = message + " " + NSLocalizedString("App is closing now", comment: "")
        }
        let downloadFinishedErrorAlert = UIAlertController(title: NSLocalizedString("Download", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
        downloadFinishedErrorAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            if killApp {
                exit(0)
            } else {
                self.propagateDelegate()
            }

        }))
        self.present(downloadFinishedErrorAlert, animated: true, completion: nil)
    }

    func propagateDelegate() {
        self.dismiss(animated: true, completion: nil)

        if self.downloadFinishedDelegate != nil {
            self.downloadFinishedDelegate.finished()
        }
    }
}
