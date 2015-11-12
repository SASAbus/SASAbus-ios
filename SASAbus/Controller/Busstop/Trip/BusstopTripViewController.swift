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

class BusstopTripViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var departure: DepartureItem!
    private var currentStopIndex: Int?
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, departure: DepartureItem) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.departure = departure
        self.currentStopIndex = nil
        if self.departure.getPositionItem() != nil && self.departure.getPositionItem()?.getLocationNumber() != nil {
            self.currentStopIndex = self.departure.getStopTimes().indexOf({$0.getBusStop() == self.departure.getPositionItem()?.getLocationNumber()})
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Bus trip", comment: "")
        tableView.registerNib(UINib(nibName: "BusstopTripTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopTripTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorColor = Theme.colorTransparent
        self.view.backgroundColor = Theme.colorDarkGrey
        self.lineLabel.textColor = Theme.colorWhite
        self.lineLabel.text = self.departure.getBusLine().getShortName() + " - "
        if self.departure.isRealTime() {
            if self.departure.getDelaySecondsRounded() == 0 {
                self.lineLabel.text = self.lineLabel.text! + NSLocalizedString("Punctual", comment: "")
            } else if self.departure.getDelaySecondsRounded() < 0 {
                self.lineLabel.text = self.lineLabel.text! + abs(self.departure.getDelaySecondsRounded()).description + "' " + NSLocalizedString("premature", comment: "")
            } else {
                self.lineLabel.text = self.lineLabel.text! + self.departure.getDelaySecondsRounded().description + "' " + NSLocalizedString("delayed", comment: "")
            }
        } else {
            self.lineLabel.text = self.lineLabel.text! + NSLocalizedString("no data", comment: "")
        }
        if self.currentStopIndex != nil {
            var scrollIndex = self.currentStopIndex!
            if scrollIndex > 1 {
                scrollIndex = scrollIndex - 1
            }
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: scrollIndex, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departure.getStopTimes().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let stop = self.departure.getStopTimes()[indexPath.row]
        let busStation = (SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]).find({$0.getBusStops().find({$0.getNumber() == stop.getBusStop()}) != nil})
        let cell = tableView.dequeueReusableCellWithIdentifier("BusstopTripTableViewCell", forIndexPath: indexPath) as! BusstopTripTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.timeLabel.text = stop.getTime()
        cell.busStationLabel.text = busStation?.getDescription()
        if self.currentStopIndex != nil && indexPath.row < self.currentStopIndex {
            cell.contentView.alpha = 0.3
        } else {
            cell.contentView.alpha = 1.0
        }
        if indexPath.row == 0 {
            cell.setImageFromType(BusstopTripTableViewCell.TYPE_START)
        } else if indexPath.row == self.departure.getStopTimes().count - 1 {
            cell.setImageFromType(BusstopTripTableViewCell.TYPE_END)
        } else {
            cell.setImageFromType(BusstopTripTableViewCell.TYPE_MIDDLE)
        }
        cell.iconImageView.image = cell.iconImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        
        return cell;
    }
}
