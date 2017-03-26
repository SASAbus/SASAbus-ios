//
// MenuTableViewCell.swift
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

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.titleLabel.textColor = Theme.colorWhite
            self.iconImageView.tintColor = Theme.colorWhite
        } else {
            self.titleLabel.textColor = Theme.colorLightGrey
            self.iconImageView.tintColor = Theme.colorLightGrey
            self.indicatorView.backgroundColor = Theme.colorTransparent
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected) {
            self.setHighlighted(true, animated: animated)
            self.indicatorView.backgroundColor = Theme.colorOrange
        } else {
            self.setHighlighted(false, animated: animated)
        }
    }
}
  
