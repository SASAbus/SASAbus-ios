//
// BusstopTripViewController.swift
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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <<T:Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class BusstopTripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    fileprivate var departure: DepartureItem!
    fileprivate var currentStopIndex: Int?

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, departure: DepartureItem) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.departure = departure
        self.currentStopIndex = nil

        if self.departure.positionItem != nil && self.departure.positionItem?.locationNumber != nil {
            self.currentStopIndex = self.departure.stopTimes.index(where: { $0.busStop == self.departure.positionItem?.locationNumber })
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Bus trip", comment: "")

        tableView.register(UINib(nibName: "BusstopTripTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopTripTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorColor = Theme.colorTransparent

        self.view.backgroundColor = Theme.colorDarkGrey
        self.lineLabel.textColor = Theme.colorWhite
        self.lineLabel.text = self.departure.busLine.name + " - "

        if self.departure.realTime {
            if self.departure.delaySecondsRounded == 0 {
                self.lineLabel.text = self.lineLabel.text! + NSLocalizedString("Punctual", comment: "")
            } else if self.departure.delaySecondsRounded < 0 {
                self.lineLabel.text = self.lineLabel.text! + abs(self.departure.delaySecondsRounded).description + "' " + NSLocalizedString("premature", comment: "")
            } else {
                self.lineLabel.text = self.lineLabel.text! + self.departure.delaySecondsRounded.description + "' " + NSLocalizedString("delayed", comment: "")
            }
        } else {
            self.lineLabel.text = self.lineLabel.text! + NSLocalizedString("no data", comment: "")
        }

        if self.currentStopIndex != nil {
            var scrollIndex = self.currentStopIndex!
            if scrollIndex > 1 {
                scrollIndex = scrollIndex - 1
            }
            self.tableView.scrollToRow(at: IndexPath(row: scrollIndex, section: 0), at: .top, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departure.stopTimes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stop = self.departure.stopTimes[indexPath.row]
        let busStation = (SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_ORT) as [BusStationItem]).find({ $0.busStops.find({ $0.number == stop.busStop }) != nil })
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusstopTripTableViewCell", for: indexPath) as! BusstopTripTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.timeLabel.text = stop.getTime()
        cell.busStationLabel.text = busStation?.getDescription()

        if self.currentStopIndex != nil && indexPath.row < self.currentStopIndex {
            cell.contentView.alpha = 0.3
        } else {
            cell.contentView.alpha = 1.0
        }

        if indexPath.row == 0 {
            cell.setImageFromType(BusstopTripTableViewCell.TYPE_START)
        } else if indexPath.row == self.departure.stopTimes.count - 1 {
            cell.setImageFromType(BusstopTripTableViewCell.TYPE_END)
        } else {
            cell.setImageFromType(BusstopTripTableViewCell.TYPE_MIDDLE)
        }

        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

        return cell;
    }
}
