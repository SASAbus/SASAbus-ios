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

class DepartureViewController: MasterViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: MasterTableView!

    var filterImage = UIImage(named: "filter_icon.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    var filterImageFilled = UIImage(named: "filter_icon_filled.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

    var departures: [DepartureItem] = []
    var filteredDepartures: [DepartureItem] = []
    var searchDate: Date!
    var secondsFromMidnight: Int!
    var filteredBusLines: [BusLineFilter] = []
    var filter = false
    var refreshControl: UIRefreshControl!

    var cellNibName: String!
    var working: Bool! = false

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
        self.refreshControl.addTarget(self, action: #selector(getDepartures), for: UIControlEvents.valueChanged)

        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])

        self.tableView.addSubview(self.refreshControl)

        self.setupSearchDate()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDepartures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let departure = self.filteredDepartures[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureTableViewCell", for: indexPath) as! DepartureTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.timeLabel.text = departure.busTripStopTime.getTime()

        if departure.realTime {
            if departure.delaySecondsRounded == 0 {
                cell.delayLabel.text = NSLocalizedString("Punctual", comment: "")
                cell.setDelayColor(Theme.green)
            } else if departure.delaySecondsRounded < 0 {
                cell.delayLabel.text = abs(departure.delaySecondsRounded).description + "' " + NSLocalizedString("premature", comment: "")
                cell.setDelayColor(Theme.blue)
            } else {
                cell.delayLabel.text = departure.delaySecondsRounded.description + "' " + NSLocalizedString("delayed", comment: "")

                if departure.delaySecondsRounded <= 5 {
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
            if departure.positionItem != nil {
                currentStopNumber = departure.positionItem!.locationNumber
            } else {
                currentStopNumber = departure.busStopNumber
            }

            let currentBusStation = (SasaDataHelper.getData(SasaDataHelper.REC_ORT) as [BusStationItem])
                    .find({ $0.busStops.find({ $0.number == currentStopNumber }) != nil })

            if currentBusStation != nil {
                cell.infoLabel.text = currentBusStation!.getDescription()
            } else {
                cell.infoLabel.text = NSLocalizedString("no Data", comment: "")
            }
        } else {
            cell.infoLabel.text = departure.busLine.name
        }

        cell.directionLabel.text = departure.destinationBusStation?.descriptionIt

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busStopTripViewController = BusStopTripViewController(departure: self.filteredDepartures[indexPath.row])

        self.navigationController!.pushViewController(busStopTripViewController, animated: true)
    }


    func setupSearchDate() {
        self.searchDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
    }

    func getDepartures() {
        print("Loading departures")

        let busLineVariantTripResult = self.getBusLineVariantTripsAndIdentifiers(self.secondsFromMidnight)
        let busLineVariantTrips: [BusLineVariantTrip] = busLineVariantTripResult.busLineVariantTrips
        let lineVariantIdentifiers: [String] = busLineVariantTripResult.lineVariantIdentifiers

        if lineVariantIdentifiers.count > 0 {
            self.disableSearching()
            if self.departures.count == 0 {
                self.tableView.started()
            }
        }

        let busStations = SasaDataHelper.getData(SasaDataHelper.REC_ORT) as [BusStationItem]
        var busStationDictionary = [Int: BusStationItem]()

        if lineVariantIdentifiers.isEmpty {
            Log.warning("No lines to load")
            return
        }

        RealtimeApi.lines(lines: lineVariantIdentifiers)
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { buses in
                    var departures: [DepartureItem] = []
                    var filteredBusLines: [BusLineFilter] = []

                    for (count, busLineVariantTrip) in busLineVariantTrips.enumerated() {
                        let stopTimes: [BusTripBusStopTime] = BusTripCalculator.calculateBusStopTimes(busLineVariantTrip)
                        let stopTimesCount = stopTimes.count
                        let destinationBusStation: BusStationItem?
                        let busStopKey = stopTimes[stopTimesCount - 1].busStop

                        if busStationDictionary.keys.contains(busStopKey!) {
                            destinationBusStation = busStationDictionary[busStopKey!]
                        } else {
                            destinationBusStation = busStations.find({ $0.busStops.find({ $0.number == busStopKey }) != nil })
                            busStationDictionary[busStopKey!] = destinationBusStation
                        }

                        let positionItem: RealtimeBus? = buses.find({ $0.trip == busLineVariantTrip.trip.tripId })
                        var delayStopFoundIndex = 9999
                        var delaySecondsRoundedToMin = 0
                        var realTime = false
                        var departureIndex = 9999

                        for index in 0 ... stopTimesCount - 1 {
                            let stopTime = stopTimes[index]
                            if (positionItem != nil) {
                                if (stopTime.seconds > (self.secondsFromMidnight - positionItem!.delay)) {
                                    positionItem!.locationNumber = stopTimes[index].busStop
                                    departureIndex = index
                                    delayStopFoundIndex = index
                                    delaySecondsRoundedToMin = positionItem!.delay
                                    realTime = true
                                    break
                                }
                            } else {
                                if (stopTime.seconds > self.secondsFromMidnight) {
                                    departureIndex = index
                                    break
                                }
                            }
                        }

                        for index in 0 ... stopTimesCount - 1 {
                            let stopTime = stopTimes[index]

                            if (self.checkIfBusStopIsSuitable(stopTime, index: index, delayStopFoundIndex: delayStopFoundIndex,
                                    delay: delaySecondsRoundedToMin, secondsFromMidnight: self.secondsFromMidnight, realtimeBus: positionItem)) {

                                departures.append(DepartureItem(stopTime: stopTime, destination: destinationBusStation,
                                        line: busLineVariantTrip.busLine, busStopNumber: stopTime.busStop, text: "",
                                        stopTimes: stopTimes, index: index, departureIndex: departureIndex,
                                        delay: delaySecondsRoundedToMin, delayStopFoundIndex: delayStopFoundIndex,
                                        realTime: realTime, positionItem: positionItem))

                                if !filteredBusLines.contains(where: { $0.busLine.id == busLineVariantTrip.busLine.id }) {
                                    filteredBusLines.append(BusLineFilter(busLine: busLineVariantTrip.busLine))
                                }
                                break
                            }
                        }

                        if (self.departures.count == 0) {
                            self.tableView.progress(Int((100 * count) / busLineVariantTrips.count))
                        }
                    }

                    departures = departures.sorted(by: { $0.busTripStopTime.seconds < $1.busTripStopTime.seconds })

                    self.departures = departures
                    self.tableView.finished()
                    self.setFilteredBusLines(filteredBusLines)
                }, onError: { error in
                    Log.error(error)
                })
    }

    func setFilteredBusLines(_ filteredBusLines: [BusLineFilter]) {
        self.filteredBusLines = filteredBusLines
        var filteredDepartures = self.departures

        if self.filteredBusLines.count > 0 {
            let activeLines = self.filteredBusLines.filter({ $0.active })
            if self.filter {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.filterImage,
                        style: UIBarButtonItemStyle.plain, target: self, action: Selector("goToFilter"))

                if activeLines.count != self.filteredBusLines.count {
                    self.navigationItem.rightBarButtonItem?.image = self.filterImageFilled
                    filteredDepartures = self.departures.filter({ activeLines.map({ $0.busLine.id }).contains($0.busLine.id) })
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
        self.enableSearching()
    }

    func disableSearching() {
        fatalError("blockSearching has not been implemented")
    }

    func enableSearching() {
        fatalError("blockSearching has not been implemented")
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
}
