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

class DownloadViewController: UIViewController {

    @IBOutlet var downloadProgress: KDCircularProgress!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    let downloader: DownloaderProtocol!
    let downloadFinishedDelegate: DownloadFinishedProtocol!
    var canBeCanceled:Bool!
    var showFinishedDialog:Bool!
    var askForDownload:Bool!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, downloader: DownloaderProtocol, downloadFinishedDelegate:DownloadFinishedProtocol!, canBeCanceled:Bool, showFinishedDialog:Bool? = true, askForDownload:Bool? = false) {
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
        self.view.backgroundColor = Theme.colorDarkGrey
        self.downloadProgress.angle = 0
        self.downloadProgress.progressThickness = 0.04
        self.downloadProgress.trackThickness = 0.05
        self.downloadProgress.clockwise = true
        self.downloadProgress.center = view.center
        self.downloadProgress.gradientRotateSpeed = 100
        self.downloadProgress.roundedCorners = true
        self.downloadProgress.glowMode = .NoGlow
        self.downloadProgress.trackColor = Theme.colorWhite
        self.downloadProgress.setColors(Theme.colorOrange ,Theme.colorOrange, Theme.colorOrange)
        self.downloadProgress.hidden = true
        self.titleLabel.hidden = true
        self.progressLabel.hidden = true
        self.cancelButton.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if  (self.downloader is SasaBusDownloader) {
                
            if UserDefaultHelper.instance.getDataDownloadStatus() == false {
                self.startDownload()
            } else {
                    
                Alamofire.request(SasaOpenDataApiRouter.GetExpirationDate()).responseObject { (response: Response<ExpirationItem, NSError>) in
                    if (response.result.isSuccess) {
                        do {
                            let expirationItemServer = response.result.value
                            let expirationItemLocal: ExpirationItem =  try SasaDataHelper.instance.getSingleElementForRepresentation(SasaDataHelper.ExpirationDate)! as ExpirationItem
                                
                            if NSCalendar.currentCalendar().compareDate((expirationItemServer?.getExpirationDate())!, toDate: expirationItemLocal.getExpirationDate(), toUnitGranularity: NSCalendarUnit.Day) != NSComparisonResult.OrderedSame {
                                self.startDownload()
                            } else {
                                self.cancelButtonDown([])
                            }
                        } catch {
                            self.startDownload()
                        }
                    } else {
                        self.cancelButtonDown([])
                    }
                }
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
        self.downloadProgress.hidden = false
        self.titleLabel.hidden = false
        self.progressLabel.hidden = false
        self.cancelButton.hidden = !self.canBeCanceled
        self.downloader.startDownload(DownloadViewProgressIndicator(downloadViewController: self))
    }
    
    //Refactor message hardcoded for mapdownload
    func askForDownloadDialog() {
        let toDownloadAlert = UIAlertController(title: NSLocalizedString("Download", comment: ""), message: NSLocalizedString("Do you want to download the mapdata now?", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        toDownloadAlert.addAction(UIAlertAction(title: NSLocalizedString("No later", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            UserDefaultHelper.instance.incrementAskedForDownloadsNoCount()
            self.cancelButtonDown([])
        }))
        
        toDownloadAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.startDownload()
        }))
        
        if (UserDefaultHelper.instance.getAskedForDownloadsNoCount() >= Configuration.mapHowOftenShouldIAskForMapDownload) {
            toDownloadAlert.addAction(UIAlertAction(title: NSLocalizedString("Do not ask me again", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                
                let mapDowloadReminderAlert = UIAlertController(title: NSLocalizedString("Info", comment: ""), message: NSLocalizedString("You can re enable map download in app settings", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                
                mapDowloadReminderAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
                    
                    UserDefaultHelper.instance.setAskForMapDownload(false)
                    self.cancelButtonDown([])
                }))
                
                self.presentViewController(mapDowloadReminderAlert, animated: true, completion: nil)
            }))
        }
        
        self.presentViewController(toDownloadAlert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelButtonDown(sender: AnyObject) {
        self.downloader.stopDownload()
        self.dismissViewControllerAnimated(true, completion: nil)
        if self.downloadFinishedDelegate != nil {
            self.downloadFinishedDelegate.finished()
        }
    }
    
    func downloadFinished() {
        if self.showFinishedDialog == true {
            let downloadFinishedAlert = UIAlertController(title: NSLocalizedString("Download", comment: ""), message: NSLocalizedString("Download finished successfully", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            
            downloadFinishedAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { (action: UIAlertAction!) in
                self.propagateDelegate()
        
            }))
            self.presentViewController(downloadFinishedAlert, animated: true, completion: nil)
        }
        else {
            self.propagateDelegate()
        }
    }
    
    func downloadFinishedWithError(errorMessage:String, killApp:Bool) {
        
        var message = errorMessage
        if killApp == true {
            message = message + " " + NSLocalizedString("App is closing now", comment: "")
        }
        let downloadFinishedErrorAlert = UIAlertController(title: NSLocalizedString("Download", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        downloadFinishedErrorAlert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { (action: UIAlertAction!) in
            if killApp {
                exit(0)
            } else {
                self.propagateDelegate()
            }
            
        }))
        self.presentViewController(downloadFinishedErrorAlert, animated: true, completion: nil)
    }
    
    func propagateDelegate () {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if self.downloadFinishedDelegate != nil {
            self.downloadFinishedDelegate.finished()
        }
    }
}
