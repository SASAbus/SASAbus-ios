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

    func started(_ title: String?) {
        DispatchQueue.main.async {
            //circularProgress.angle = progress
            if title != nil {
                self.downloadViewController.titleLabel.text = title
            }
            self.downloadViewController.progressLabel.text = NSLocalizedString("Download started", comment: "")
        }
    }

    func progress(_ percent: Int, description: String? = nil) {
        var description = description

        DispatchQueue.main.async {
            //circularProgress.angle = progress
            let newAngleValue = Double((360 * percent) / 100)

            if description == nil {
                description = NSLocalizedString("\(percent)%", comment: "")
            }

            self.downloadViewController.progressLabel.text = description

            if (self.downloadViewController.downloadProgress.angle < newAngleValue) {
                self.downloadViewController.downloadProgress.animate(toAngle: newAngleValue, duration: 0.05, completion: nil)
            }
        }
    }

    func finished() {
        DispatchQueue.main.async {
            self.downloadViewController.downloadFinished()
        }
    }

    func error(_ message: String?, fatal: Bool) {
        DispatchQueue.main.async {
            self.downloadViewController.progressLabel.text = message
            self.downloadViewController.downloadFinishedWithError(message!, killApp: fatal)
        }
    }

    func reset(_ newTitle: String? = nil) {
        DispatchQueue.main.async {
            if newTitle != nil {
                self.downloadViewController.titleLabel.text = newTitle
            }

            self.downloadViewController.downloadProgress.angle = 0
            self.downloadViewController.cancelButton.isHidden = true // Cancel button should be hidden for map download
            self.downloadViewController.downloadProgress.animate(toAngle: 0, duration: 0, completion: nil)
        }
    }
}
