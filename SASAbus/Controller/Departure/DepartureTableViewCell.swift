//
// DepartureTableViewCell.swift
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

class DepartureTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    fileprivate var delayColor = Theme.colorDarkGrey

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.timeLabel.textColor = Theme.colorWhite
            self.infoLabel.textColor = Theme.colorWhite
            self.delayLabel.textColor = Theme.colorWhite
            self.directionLabel.textColor = Theme.colorWhite
            self.iconImageView.tintColor = Theme.colorWhite
            self.backgroundColor = Theme.colorOrange
        } else {
            self.timeLabel.textColor = Theme.colorDarkGrey
            self.delayLabel.textColor = self.delayColor
            self.infoLabel.textColor = Theme.colorDarkGrey
            self.directionLabel.textColor = Theme.colorDarkGrey
            self.iconImageView.tintColor = Theme.colorOrange
            self.backgroundColor = Theme.colorTransparent
        }
    }

    func setDelayColor(_ color: UIColor) {
        self.delayColor = color
    }
}
