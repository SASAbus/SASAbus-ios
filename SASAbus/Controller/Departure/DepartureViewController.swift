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

class DepartureViewController: MasterViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: MasterTableView!

    internal var filterImage = UIImage(named: "filter_icon.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    internal var filterImageFilled = UIImage(named: "filter_icon_filled.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    internal var departures: [DepartureItem] = []
    internal var filteredDepartures: [DepartureItem] = []
    internal var searchDate: Date!
    internal var secondsFromMidnight: Int!
    internal var filteredBusLines: [BusLineFilter] = []
    internal var filter = false
    internal var refreshControl: UIRefreshControl!
    fileprivate var cellNibName: String!
    internal var working: Bool! = false

    init(cellNibName: String, nibName nibNameOrNil: String?, title: String?) {
        super.init(nibName: nibNameOrNil, title: title)
        self.cellNibName = cellNibName
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: self.cellNibName, bundle: nil), forCellReuseIdentifier: "DepartureTableViewCell");

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.initRefreshControl()
        self.setupSearchDate()
    }

    internal func setupSearchDate() {
        self.searchDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
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
                cell.setDelayColor(Theme.colorGreen)
            } else if departure.delaySecondsRounded < 0 {
                cell.delayLabel.text = abs(departure.delaySecondsRounded).description + "' " + NSLocalizedString("premature", comment: "")
                cell.setDelayColor(Theme.colorBlue)
            } else {
                cell.delayLabel.text = departure.delaySecondsRounded.description + "' " + NSLocalizedString("delayed", comment: "")

                if departure.delaySecondsRounded <= 5 {
                    cell.setDelayColor(Theme.colorOrange)
                } else {
                    cell.setDelayColor(Theme.colorRed)
                }
            }
        } else {
            cell.delayLabel.text = NSLocalizedString("no data", comment: "")
            cell.setDelayColor(Theme.colorDarkGrey)
        }
        if self.cellNibName == "DepartureBuslineTableViewCell" {
            let currentStopNumber: Int!
            if departure.positionItem != nil {
                currentStopNumber = departure.positionItem!.locationNumber
            } else {
                currentStopNumber = departure.busStopNumber
            }
            let currentBusStation = (SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_ORT) as [BusStationItem]).find(predicate: { $0.busStops.find(predicate: { $0.number == currentStopNumber }) != nil })
            if currentBusStation != nil {
                cell.infoLabel.text = currentBusStation!.getDescription()
            } else {
                cell.infoLabel.text = NSLocalizedString("no Data", comment: "")
            }
        } else {
            cell.infoLabel.text = departure.busLine.name
        }
        cell.directionLabel.text = departure.destinationBusStation?.descriptionIt
        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busstopTripViewController = BusstopTripViewController(nibName: "BusstopTripViewController", bundle: nil, departure: self.filteredDepartures[indexPath.row]);
        self.navigationController!.pushViewController(busstopTripViewController, animated: true)
    }

    func getDepartures() {
        print("Loading departures")

        let busLineVariantTripResult = self.getBusLineVariantTripsAndIdentifiers(self.secondsFromMidnight)
        let busLineVariantTrips: [BusLineVariantTrip] = busLineVariantTripResult.getBusLineVariantTrips()
        let lineVariantIdentifiers: [String] = busLineVariantTripResult.getLineVariantIdentifiers()

        if lineVariantIdentifiers.count > 0 {
            self.disableSearching()
            if self.departures.count == 0 {
                self.tableView.started()
            }
        }

        let busStations = SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_ORT) as [BusStationItem]
        var busStationDictionary = [Int: BusStationItem]()

        Alamofire.request(RealTimeDataApiRouter.getPositionForLineVariants(lineVariantIdentifiers)).responseJSON { response in
            var departures: [DepartureItem] = []
            var positionItems: [RealtimeBus] = []
            var filteredBusLines: [BusLineFilter] = []

            if (response.result.isSuccess) {
                positionItems = RealtimeBus.collection(parameter: JSON(response.data))
            }

            for (count, busLineVariantTrip) in busLineVariantTrips.enumerated() {
                let stopTimes: [BusTripBusStopTime] = BusTripCalculator.calculateBusStopTimes(busLineVariantTrip)
                let stopTimesCount = stopTimes.count
                let destinationBusStation: BusStationItem?
                let busStopKey = stopTimes[stopTimesCount - 1].busStop

                if busStationDictionary.keys.contains(busStopKey!) {
                    destinationBusStation = busStationDictionary[busStopKey!]
                } else {
                    destinationBusStation = busStations.find(predicate: { $0.busStops.find(predicate: { $0.number == busStopKey }) != nil })
                    busStationDictionary[busStopKey!] = destinationBusStation
                }

                let positionItem: RealtimeBus? = positionItems.find(predicate: { $0.trip == busLineVariantTrip.trip.tripId })
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
                    if (self.checkIfBusStopIsSuitable(stopTime, index: index, delayStopFoundIndex: delayStopFoundIndex, delaySecondsRoundedToMin: delaySecondsRoundedToMin, secondsFromMidnight: self.secondsFromMidnight, positionItem: positionItem)) {
                        departures.append(DepartureItem(busTripStopTime: stopTime, destinationBusStation: destinationBusStation, busLine: busLineVariantTrip.busLine, busStopNumber: stopTime.busStop, text: "", stopTimes: stopTimes, index: index, departureIndex: departureIndex, delaySecondsRounded: delaySecondsRoundedToMin, delayStopFoundIndex: delayStopFoundIndex, realTime: realTime, positionItem: positionItem))
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
        }
    }

    internal func setFilteredBusLines(_ filteredBusLines: [BusLineFilter]) {
        self.filteredBusLines = filteredBusLines
        var filteredDepartures = self.departures

        if self.filteredBusLines.count > 0 {
            let activeLines = self.filteredBusLines.filter({ $0.active })
            if self.filter {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.filterImage, style: UIBarButtonItemStyle.plain, target: self, action: Selector("goToFilter"))

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

    internal func disableSearching() {
        fatalError("blockSearching has not been implemented")
    }

    internal func enableSearching() {
        fatalError("blockSearching has not been implemented")
    }

    internal func getBusLineVariantTripsAndIdentifiers(_ secondsFromMidnight: Int) -> BusLineVariantTripResult {
        fatalError("getBusLineVariantTripsAndIdentifiers(secondsFromMidnight:) has not been implemented")
    }

    internal func getSecondsFromMidnight(_ date: Date) -> Int {
        let components = (Calendar.current as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second], from: date)
        return (components.hour! * 60 + components.minute!) * 60
    }

    internal func checkIfBusStopIsSuitable(_ busTripStopTime: BusTripBusStopTime, index: Int, delayStopFoundIndex: Int, delaySecondsRoundedToMin: Int, secondsFromMidnight: Int, positionItem: RealtimeBus?) -> Bool {
        fatalError("checkIfBusStopIsSuitable(secondsFromMidnight:index:delayStopFoundIndex:delaySecondsRoundedToMin:secodsFromMidnight:positionItem:) has not been implemented")
    }

    fileprivate func initRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Theme.colorLightOrange
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""), attributes: [NSForegroundColorAttributeName: Theme.colorDarkGrey])
        self.refreshControl.addTarget(self, action: #selector(DepartureViewController.getDepartures), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }

}
