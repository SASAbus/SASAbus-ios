//
// MasterTableView.swift
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
import UIKit

class MasterTableView: UITableView {

    var backgroundImageView: BackgroundView!

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        self.backgroundImageView = BackgroundView(frame: self.frame)
        self.backgroundImageView.bounds = self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.backgroundImageView = BackgroundView(frame: self.frame)
        self.backgroundImageView.bounds = self.bounds
    }

    override func reloadData() {
        super.reloadData()
        var rows = 0

        for section in 0 ... self.numberOfSections - 1 {
            rows += self.numberOfRows(inSection: section)
        }

        if rows == 0 {
            self.backgroundImageView.alpha = 0.3
            self.backgroundView = self.backgroundImageView
        } else {
            self.backgroundImageView.alpha = 0.0
            self.backgroundView = self.backgroundImageView
        }
    }

    func started(_ title: String? = nil) {
        DispatchQueue.main.async {
            self.backgroundImageView!.alpha = 1.0
            self.backgroundView = self.backgroundImageView
        }
    }

    func progress(_ percent: Int, description: String? = nil) {
        DispatchQueue.main.async {
            if self.backgroundImageView.progressIndicatorView.layer.presentation() != nil {
                let newAngleValue = Double((360 * percent) / 100)

                if self.backgroundImageView.progressIndicatorView.angle != newAngleValue {
                    self.backgroundImageView.progressIndicatorView.animate(toAngle: newAngleValue,
                            duration: 0.02, completion: nil)
                }
            }
        }
    }

    func error(_ message: String?, fatal: Bool) {
        DispatchQueue.main.async {
        }
    }

    func finished() {
        DispatchQueue.main.async {
            if self.backgroundImageView.progressIndicatorView.layer.presentation() != nil {
                self.backgroundImageView.progressIndicatorView.animate(toAngle: 0, duration: 0, completion: nil)
            }

            self.backgroundImageView.alpha = 0.0
            self.backgroundView = self.backgroundImageView
        }
    }

    func reset(_ newTitle: String? = nil) {

    }
}
