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

class DepartureViewController: MasterViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: MasterTableView!
    
    internal var filterImage = UIImage(named: "filter_icon.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    internal var filterImageFilled = UIImage(named: "filter_icon_filled.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    internal var departures: [DepartureItem] = []
    internal var filteredDepartures: [DepartureItem] = []
    internal var searchDate: NSDate!
    internal var secondsFromMidnight: Int!
    internal var filteredBusLines: [BusLineFilter] = []
    internal var filter = false
    internal var refreshControl: UIRefreshControl!
    private var cellNibName: String!
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
        tableView.registerNib(UINib(nibName: self.cellNibName, bundle: nil), forCellReuseIdentifier: "DepartureTableViewCell");
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.initRefreshControl()
        self.setupSearchDate()
    }
    
    internal func setupSearchDate() {
        self.searchDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDepartures.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let departure = self.filteredDepartures[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("DepartureTableViewCell", forIndexPath: indexPath) as! DepartureTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.iconImageView.image = cell.iconImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.timeLabel.text = departure.getBusTripStopTime().getTime()
        if departure.isRealTime() {
            if departure.getDelaySecondsRounded() == 0 {
                cell.delayLabel.text = NSLocalizedString("Punctual", comment: "")
                cell.setDelayColor(Theme.colorGreen)
            } else if departure.getDelaySecondsRounded() < 0 {
                cell.delayLabel.text = abs(departure.getDelaySecondsRounded()).description + "' " + NSLocalizedString("premature", comment: "")
                cell.setDelayColor(Theme.colorBlue)
            } else {
                cell.delayLabel.text = departure.getDelaySecondsRounded().description + "' " + NSLocalizedString("delayed", comment: "")
                if departure.getDelaySecondsRounded() <= 5 {
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
            if departure.getPositionItem() != nil {
                currentStopNumber = departure.getPositionItem()!.getLocationNumber()
            } else {
                currentStopNumber = departure.getBusStopNumber()
            }
            let currentBusStation = (SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]).find({$0.getBusStops().find({$0.getNumber() == currentStopNumber}) != nil})
            if currentBusStation != nil {
                cell.infoLabel.text = currentBusStation!.getDescription()
            } else {
                cell.infoLabel.text = NSLocalizedString("no Data", comment: "")
            }
        } else {
            cell.infoLabel.text = departure.getBusLine().getShortName()
        }
        cell.directionLabel.text = departure.getDestinationBusStation()?.getDescription()
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let busstopTripViewController = BusstopTripViewController(nibName: "BusstopTripViewController", bundle: nil, departure: self.filteredDepartures[indexPath.row]);
        self.navigationController!.pushViewController(busstopTripViewController, animated: true)
    }
    
    func getDepartures() {
        let busLineVariantTripResult = self.getBusLineVariantTripsAndIdentifiers(self.secondsFromMidnight)
        let busLineVariantTrips: [BusLineVariantTrip] = busLineVariantTripResult.getBusLineVariantTrips()
        let lineVariantIdentifiers: [String] = busLineVariantTripResult.getLineVariantIdentifiers()
        if lineVariantIdentifiers.count > 0 {
            self.disableSearching()
            if self.departures.count == 0 {
                self.tableView.started()
            }
        }
        let busStations = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]
        var busStationDictionary = [Int : BusStationItem]()
        Alamofire.request(RealTimeDataApiRouter.GetPositionForLineVariants(lineVariantIdentifiers)).responseCollection { (response: Response<[PositionItem], NSError>) in
            var departures: [DepartureItem] = []
            var positionItems: [PositionItem] = []
            var filteredBusLines: [BusLineFilter] = []
            if (response.result.isSuccess) {
                positionItems = response.result.value!
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                for (count, busLineVariantTrip) in busLineVariantTrips.enumerate() {
                    let stopTimes: [BusTripBusStopTime] = BusTripCalculator.calculateBusStopTimes(busLineVariantTrip)
                    let stopTimesCount = stopTimes.count
                    let destinationBusStation:BusStationItem?
                    let busStopKey = stopTimes[stopTimesCount - 1].getBusStop()
                    if busStationDictionary.keys.contains(busStopKey) {
                        destinationBusStation = busStationDictionary[busStopKey]
                    } else {
                        destinationBusStation = busStations.find({$0.getBusStops().find({$0.getNumber() == busStopKey}) != nil})
                        busStationDictionary[busStopKey] = destinationBusStation
                    }
                    let positionItem: PositionItem? = positionItems.find({$0.getTripId() == busLineVariantTrip.getTrip().getTripId()})
                    var delayStopFoundIndex = 9999
                    var delaySecondsRoundedToMin = 0
                    var realTime = false
                    var departureIndex = 9999
                    for index in 0...stopTimesCount - 1 {
                        let stopTime = stopTimes[index]
                        if (positionItem != nil) {
                            if (stopTime.getSeconds() > (self.secondsFromMidnight - positionItem!.getDelay())) {
                                positionItem!.setLocationNumber(stopTimes[index].getBusStop())
                                departureIndex = index
                                delayStopFoundIndex = index
                                delaySecondsRoundedToMin = positionItem!.getDelayRoundedToMinutes()
                                realTime = true
                                break
                            }
                        } else {
                            if (stopTime.getSeconds() > self.secondsFromMidnight) {
                                departureIndex = index
                                break
                            }
                        }
                    }
                    for index in 0...stopTimesCount - 1 {
                        let stopTime = stopTimes[index]
                        if (self.checkIfBusStopIsSuitable(stopTime, index: index, delayStopFoundIndex: delayStopFoundIndex, delaySecondsRoundedToMin: delaySecondsRoundedToMin, secondsFromMidnight: self.secondsFromMidnight, positionItem: positionItem)) {
                            departures.append(DepartureItem(busTripStopTime: stopTime, destinationBusStation:destinationBusStation, busLine: busLineVariantTrip.getBusLine(), busStopNumber: stopTime.getBusStop(), text: "", stopTimes: stopTimes, index: index, departureIndex: departureIndex, delaySecondsRounded: delaySecondsRoundedToMin, delayStopFoundIndex: delayStopFoundIndex, realTime: realTime, positionItem: positionItem))
                            if !filteredBusLines.contains({$0.getBusLine().getNumber() == busLineVariantTrip.getBusLine().getNumber()}) {
                                filteredBusLines.append(BusLineFilter(busLine: busLineVariantTrip.getBusLine()))
                            }
                            break
                        }
                    }
                    if (self.departures.count == 0) {
                        self.tableView.progress(Int((100 * count) / busLineVariantTrips.count))
                    }
                }
                departures = departures.sort({$0.getBusTripStopTime().getSeconds() < $1.getBusTripStopTime().getSeconds()})
                self.departures = departures
                self.tableView.finished()
                dispatch_async(dispatch_get_main_queue()) {
                    self.setFilteredBusLines(filteredBusLines)
                }
            }
        }
    }
    
    internal func setFilteredBusLines(filteredBusLines: [BusLineFilter]) {
        self.filteredBusLines = filteredBusLines
        var filteredDepartures = self.departures
        if self.filteredBusLines.count > 0 {
            let activeLines = self.filteredBusLines.filter({$0.isActive()})
            if self.filter {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.filterImage, style: UIBarButtonItemStyle.Plain, target: self, action: "goToFilter")
                if activeLines.count != self.filteredBusLines.count {
                    self.navigationItem.rightBarButtonItem?.image = self.filterImageFilled
                    filteredDepartures = self.departures.filter({activeLines.map({$0.getBusLine().getNumber()}).contains($0.getBusLine().getNumber())})
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
    
    internal func getBusLineVariantTripsAndIdentifiers(secondsFromMidnight: Int) -> BusLineVariantTripResult {
        fatalError("getBusLineVariantTripsAndIdentifiers(secondsFromMidnight:) has not been implemented")
    }
    
    internal func getSecondsFromMidnight(date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date)
        return (components.hour * 60 + components.minute) * 60
    }
    
    internal func checkIfBusStopIsSuitable(busTripStopTime: BusTripBusStopTime, index: Int, delayStopFoundIndex: Int, delaySecondsRoundedToMin: Int, secondsFromMidnight: Int, positionItem: PositionItem?) -> Bool {
        fatalError("checkIfBusStopIsSuitable(secondsFromMidnight:index:delayStopFoundIndex:delaySecondsRoundedToMin:secodsFromMidnight:positionItem:) has not been implemented")
    }
    
    private func initRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Theme.colorLightOrange
        self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""), attributes: [NSForegroundColorAttributeName: Theme.colorDarkGrey])
        self.refreshControl.addTarget(self, action: "getDepartures", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
}
