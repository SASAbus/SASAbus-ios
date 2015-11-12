//
// DownloadViewProgressIndicator.swift
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

import Foundation

class DownloadViewProgressIndicator: ProgressIndicatorProtocol {
    
    let downloadViewController: DownloadViewController!
    
    init(downloadViewController: DownloadViewController!) {
        self.downloadViewController = downloadViewController
    }
    
    func started(title:String?) {
        dispatch_async(dispatch_get_main_queue()) {
            //circularProgress.angle = progress
            if title != nil {
                self.downloadViewController.titleLabel.text = title
            }
            self.downloadViewController.progressLabel.text = NSLocalizedString("Download started", comment: "")
        }
    }
    func progress(percent:Int, var description:String? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            //circularProgress.angle = progress
            let newAngleValue = Int((360 * percent) / 100 )
            if description == nil {
                description = NSLocalizedString("\(percent)%", comment: "")
            }
            self.downloadViewController.progressLabel.text = description
            if (self.downloadViewController.downloadProgress.angle < newAngleValue) {
                self.downloadViewController.downloadProgress.animateToAngle(newAngleValue, duration: 0.05, completion: nil)
            }
        }
    }
    
    func finished() {
        dispatch_async(dispatch_get_main_queue()) {
            self.downloadViewController.downloadFinished()
        }
    }
    
    func error(message: String?, fatal:Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.downloadViewController.progressLabel.text = message
            self.downloadViewController.downloadFinishedWithError(message!, killApp:fatal)
        }
    }
    
    func reset(newTitle:String? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            if newTitle != nil {
                self.downloadViewController.titleLabel.text = newTitle
            }
            self.downloadViewController.downloadProgress.angle = 0
            self.downloadViewController.cancelButton.hidden = true //cancel button should be hidden for map download
            self.downloadViewController.downloadProgress.animateToAngle(0, duration: 0, completion: nil)
        }
    }
}