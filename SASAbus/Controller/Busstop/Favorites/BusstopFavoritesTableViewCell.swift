//
// BusstopFavoritesTableViewCell.swift
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

class BusstopFavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var busStationLabel: UILabel!
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.busStationLabel.textColor = Theme.colorWhite
            self.backgroundColor = Theme.colorOrange
        } else {
            self.busStationLabel.textColor = Theme.colorDarkGrey
            self.backgroundColor = Theme.colorTransparent
        }
    }
}
