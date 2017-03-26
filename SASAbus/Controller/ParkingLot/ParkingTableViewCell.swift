//
// ParkingTableViewCell.swift
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

class ParkingTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var phoneLabel: UITextView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.titleLabel.textColor = Theme.colorWhite
            self.messageLabel.textColor = Theme.colorWhite
            self.addressLabel.textColor = Theme.colorWhite
            self.phoneLabel.tintColor = Theme.colorWhite
            self.progressView.progressTintColor = Theme.colorWhite
            self.iconImageView.tintColor = Theme.colorWhite
            self.backgroundColor = Theme.colorDarkGrey
        } else {
            self.titleLabel.textColor = Theme.colorDarkGrey
            self.messageLabel.textColor = Theme.colorDarkGrey
            self.addressLabel.textColor = Theme.colorDarkGrey
            self.phoneLabel.tintColor = nil
            self.progressView.progressTintColor = Theme.colorOrange
            self.iconImageView.tintColor = Theme.colorOrange
            self.backgroundColor = Theme.colorTransparent
        }
    }
}
