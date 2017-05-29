//
// DepartureViewController.swift
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
import Alamofire
import SwiftyJSON
import RxCocoa
import RxSwift
import RealmSwift

class DepartureViewController: MasterViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: MasterTableView!

    var filterImage = UIImage(named: "filter_icon.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    var filterImageFilled = UIImage(named: "filter_icon_filled.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

    var departures: [Departure] = []

    var searchDate: Date!
    var secondsFromMidnight: Int!
    var filteredBusLines: [BusLineFilter] = []
    var filter = false
    var refreshControl: UIRefreshControl!

    var cellNibName: String!
    var working: Bool! = false

    var realm = try! Realm(configuration: BusStopRealmHelper.CONFIG)

    init(cellNibName: String, nibName nibNameOrNil: String?, title: String?) {
        super.init(nibName: nibNameOrNil, title: title)
        self.cellNibName = cellNibName
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: self.cellNibName, bundle: nil), forCellReuseIdentifier: "DepartureTableViewCell")

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Theme.lightOrange
        self.refreshControl.addTarget(self, action: #selector(parseData), for: UIControlEvents.valueChanged)

        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])

        self.tableView.addSubview(self.refreshControl)

        self.setupSearchDate()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let departure = departures[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureTableViewCell", for: indexPath) as! DepartureTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.timeLabel.text = departure.time

        if departure.vehicle != 0 {
            if departure.delay == 0 {
                cell.delayLabel.text = NSLocalizedString("Punctual", comment: "")
                cell.setDelayColor(Theme.green)
            } else if departure.delay < 0 {
                cell.delayLabel.text = "\(abs(departure.delay))' " + NSLocalizedString("premature", comment: "")
                cell.setDelayColor(Theme.blue)
            } else {
                cell.delayLabel.text = "\(departure.delay)' " + NSLocalizedString("delayed", comment: "")

                if departure.delay <= 5 {
                    cell.setDelayColor(Theme.orange)
                } else {
                    cell.setDelayColor(Theme.red)
                }
            }
        } else {
            cell.delayLabel.text = NSLocalizedString("no data", comment: "")
            cell.setDelayColor(Theme.darkGrey)
        }

        if self.cellNibName == "DepartureBusLineTableViewCell" {
            let currentStopNumber: Int!

            if departure.vehicle != 0 {
                currentStopNumber = departure.currentBusStop
            } else {
                currentStopNumber = 0
            }

            let currentBusStation = realm.objects(BusStop.self).filter("id == \(currentStopNumber)").first

            if currentBusStation != nil {
                cell.infoLabel.text = currentBusStation!.name()
            } else {
                cell.infoLabel.text = NSLocalizedString("no Data", comment: "")
            }
        } else {
            cell.infoLabel.text = departure.line
        }

        cell.directionLabel.text = departure.destination

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busStopTripViewController = BusStopTripViewController(departure: departures[indexPath.row])

        self.navigationController!.pushViewController(busStopTripViewController, animated: true)
    }


    func setupSearchDate() {
        self.searchDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
    }

    func setFilteredBusLines(_ filteredBusLines: [BusLineFilter]) {
        // TODO filter lines?

        /*self.filteredBusLines = filteredBusLines
        var filteredDepartures = self.departures

        if self.filteredBusLines.count > 0 {
            let activeLines = self.filteredBusLines.filter({ $0.active })
            if self.filter {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.filterImage,
                        style: UIBarButtonItemStyle.plain, target: self, action: Selector("goToFilter"))

                if activeLines.count != self.filteredBusLines.count {
                    self.navigationItem.rightBarButtonItem?.image = self.filterImageFilled
                    filteredDepartures = self.departures.filter({ activeLines.map({ $0.busLine.id }).contains($0.lineId) })
                }
            }
        } else {
            if self.filter {
                self.navigationItem.rightBarButtonItem = nil
            }
        }

        self.filteredDepartures = filteredDepartures
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()

        self.enableSearching()*/
    }


    func getBusLineVariantTripsAndIdentifiers(_ secondsFromMidnight: Int) -> BusLineVariantTripResult {
        fatalError("getBusLineVariantTripsAndIdentifiers(secondsFromMidnight:) has not been implemented")
    }

    func getSecondsFromMidnight(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents(
                [Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date)

        return (components.hour! * 60 + components.minute!) * 60
    }

    func checkIfBusStopIsSuitable(_ stopTime: BusTripBusStopTime, index: Int, delayStopFoundIndex: Int,
                                  delay: Int, secondsFromMidnight: Int, realtimeBus: RealtimeBus?) -> Bool {

        fatalError("checkIfBusStopIsSuitable() not implemented")
    }


    func parseData() {
        fatalError()
    }

    func enableSearching() {
        fatalError()
    }

    func disableSearching() {
        fatalError()
    }
}
