//
// BusstopViewController.swift
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

class BusStopViewController: DepartureViewController, UITabBarDelegate, UISearchBarDelegate, UITextFieldDelegate {

    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!

    fileprivate var selectedBusStation: BusStationItem?
    @IBOutlet weak var autoCompleteTableView: UITableView!
    fileprivate let busStations: [BusStationItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_ORT) as [BusStationItem]
    fileprivate var foundBusStations: [BusStationItem] = []
    fileprivate var datePicker: UIDatePicker!
    fileprivate var observerAdded: Bool! = false


    init(busStation: BusStationItem?, title: String?) {
        super.init(cellNibName: "DepartureBusstopTableViewCell", nibName: "BusstopViewController", title: title)
        self.selectedBusStation = busStation
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.observerAdded = false
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.filter = true
        self.observerAdded = false
        self.view.backgroundColor = Theme.colorDarkGrey
        self.searchBar.barTintColor = Theme.colorDarkGrey
        self.searchBar.tintColor = Theme.colorWhite
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.setImage(UIImage(named: "ic_navigation_bus.png"), for: UISearchBarIcon.search, state: UIControlState())

        (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.colorDarkGrey
        (self.searchBar.value(forKey: "searchField") as! UITextField).clearButtonMode = UITextFieldViewMode.never

        self.tabBar.tintColor = Theme.colorOrange
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = Theme.colorWhite
        self.tabBar.items![0].title = NSLocalizedString("GPS", comment: "")
        self.tabBar.items![1].title = NSLocalizedString("Map", comment: "")
        self.tabBar.items![2].title = NSLocalizedString("Favorites", comment: "")
        self.datePicker = UIDatePicker(frame: CGRect.zero)
        self.datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        self.datePicker.backgroundColor = Theme.colorDarkGrey
        self.datePicker.tintColor = Theme.colorWhite
        self.datePicker.setValue(Theme.colorWhite, forKey: "textColor")
        self.timeField.textColor = Theme.colorWhite
        self.timeField.tintColor = Theme.colorTransparent
        self.timeField.inputView = self.datePicker
        self.setupAutoCompleteTableView()

        if self.selectedBusStation != nil {
            self.setupBusstopSearchDate()
            self.setBusStation(self.selectedBusStation!)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.setupBusstopSearchDate()
        self.autoCompleteTableView.isHidden = true
        self.tabBar.selectedItem = nil

        if self.selectedBusStation == nil {
            self.setBusStationFromCurrentLocation()
        }

        if self.observerAdded == false {
            self.observerAdded = true
            NotificationCenter.default.addObserver(self, selector: #selector(BusStopViewController.setBusStationFromCurrentLocation), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        Analytics.track("NextBus")
    }


    override func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.searchBar.endEditing(true)
        self.timeField.endEditing(true)
        super.leftDrawerButtonPress(sender)
    }

    override internal func disableSearching() {
        self.working = true

        (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.colorGrey

        self.timeField.isUserInteractionEnabled = false
        self.searchBar.alpha = 0.7
        self.timeField.alpha = 0.7

        let items = self.tabBar.items

        for item in items! {
            item.isEnabled = false
        }

        self.tabBar.setItems(items, animated: false)
    }

    override internal func enableSearching() {
        self.working = false

        (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.colorDarkGrey

        self.timeField.isUserInteractionEnabled = true
        self.searchBar.alpha = 1.0
        self.timeField.alpha = 1.0

        let items = self.tabBar.items

        for item in items! {
            item.isEnabled = true
        }

        self.tabBar.setItems(items, animated: false)
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0

        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            count = self.foundBusStations.count
        } else {
            count = super.tableView(tableView, numberOfRowsInSection: section)
        }

        return count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            let busStation = self.foundBusStations[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusstopAutocompleteTableViewCell", for: indexPath) as! BusstopAutocompleteTableViewCell

            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.busStationLabel.text = busStation.getDescription()

            return cell;
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            self.setBusStation(self.foundBusStations[indexPath.row])
        } else {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }


    override internal func checkIfBusStopIsSuitable(_ busTripStopTime: BusTripBusStopTime, index: Int, delayStopFoundIndex: Int, delaySecondsRoundedToMin: Int, secondsFromMidnight: Int, positionItem: RealtimeBus?) -> Bool {
        var suitable = false
        var delay = 0
        if (index >= delayStopFoundIndex) {
            delay = delaySecondsRoundedToMin
        }
        if (self.selectedBusStation!.containsBusStop(busTripStopTime.busStop)
                && busTripStopTime.seconds + delay >= secondsFromMidnight) {
            suitable = true
        }
        return suitable
    }

    override internal func getBusLineVariantTripsAndIdentifiers(_ secondsFromMidnight: Int) -> BusLineVariantTripResult {
        let busLineVariantTripResult: BusLineVariantTripResult = BusLineVariantTripResult()

        if self.selectedBusStation != nil {
            let busDayType = (SasaDataHelper.getDataForRepresentation(SasaDataHelper.FIRMENKALENDER) as [BusDayTypeItem])
                    .find(predicate: { (Calendar.current as NSCalendar).compare($0.date, to: self.searchDate, toUnitGranularity: NSCalendar.Unit.day) == ComparisonResult.orderedSame })

            if busDayType != nil {
                let lookBack = 60 * 60 * 2

                for busLine in self.selectedBusStation!.getBusLines() {
                    let busDayTimeTrips: [BusDayTypeTripItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.BusDayTypeTrip(busLine, dayType: busDayType!)) as [BusDayTypeTripItem]

                    for busDayTimeTrip in busDayTimeTrips {
                        for busTripVariant in busDayTimeTrip.busTripVariants {
                            for busTrip in busTripVariant.trips {
                                if busTrip.startTime > secondsFromMidnight - lookBack {
                                    busLineVariantTripResult.addBusLineVariantTrip(BusLineVariantTrip(busLine: busLine, variant: busTripVariant, trip: busTrip))
                                }
                            }
                        }
                    }
                }
            }
        }

        return busLineVariantTripResult
    }


    fileprivate func setupAutoCompleteTableView() {
        self.autoCompleteTableView!.isHidden = true
        self.updateFoundBusStations("")
        self.view.addSubview(self.autoCompleteTableView!)
        self.autoCompleteTableView!.register(UINib(nibName: "BusstopAutocompleteTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopAutocompleteTableViewCell");
    }

    fileprivate func updateFoundBusStations(_ searchText: String) {
        self.foundBusStations = self.busStations

        if searchText != "" {
            self.foundBusStations = foundBusStations.filter({ $0.getDescription().lowercased().contains(searchText.lowercased()) })
        }

        self.foundBusStations = foundBusStations.sorted(by: { $0.getDescription() < $1.getDescription() })
        self.autoCompleteTableView.reloadData()
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (self.selectedBusStation != nil) {
            self.selectedBusStation = nil
            self.getDepartures()
        }

        self.updateFoundBusStations(searchText)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return !self.working
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(BusStopViewController.searchBarCancel))
        searchBar.text = ""
        self.updateFoundBusStations(searchBar.text!)
        self.autoCompleteTableView.isHidden = false
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let activeLines = self.filteredBusLines.filter({ $0.active })

        if self.filter {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.filterImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(BusStopViewController.goToFilter))
            self.navigationItem.rightBarButtonItem!.accessibilityLabel = NSLocalizedString("Linefilter", comment: "")

            if activeLines.count != self.filteredBusLines.count {
                self.navigationItem.rightBarButtonItem?.image = self.filterImageFilled
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }

        self.foundBusStations = []
        self.autoCompleteTableView.isHidden = true
    }

    func searchBarCancel() {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
    }


    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePickerDoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.done, target: self, action: #selector(BusStopViewController.setSearchDate))
        self.navigationItem.rightBarButtonItem = datePickerDoneButton
    }

    func textField(_ textField: UITextField, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem = nil
        self.departures = []
        self.filteredDepartures = []
        self.tableView.reloadData()
        self.getDepartures()
        textField.resignFirstResponder()
    }


    func setBusStationFromCurrentLocation() {
        if UserDefaultHelper.instance.isBeaconStationDetectionEnabled() {
            let currentBusStop = UserDefaultHelper.instance.getCurrentBusStop()
            if currentBusStop != nil {
                Log.info("Current bus stop: \(currentBusStop)")

                let busStation = (SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_ORT) as [BusStationItem]).find(predicate: { $0.busStops.filter({ $0.number == currentBusStop }).count > 0 })

                if busStation != nil {
                    self.setBusStation(busStation!)
                    self.setupBusstopSearchDate()
                    self.autoCompleteTableView.isHidden = true
                    self.tabBar.selectedItem = nil
                }
            }
        }
    }

    func setupBusstopSearchDate() {
        super.setupSearchDate()
        self.datePicker.date = self.searchDate as Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.timeField.text = dateFormatter.string(from: self.searchDate as Date)
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            let busstopGpsViewController = BusstopGpsViewController(nibName: "BusstopGpsViewController", bundle: nil)
            self.navigationController!.pushViewController(busstopGpsViewController, animated: true)
        } else if item.tag == 1 {
            let busstopMapViewController = BusstopMapViewController(nibName: "BusstopMapViewController", bundle: nil)
            self.navigationController!.pushViewController(busstopMapViewController, animated: true)
        } else if item.tag == 2 {
            let busstopFavoritesViewController = BusstopFavoritesViewController(nibName: "BusstopFavoritesViewController", bundle: nil, busStation: self.selectedBusStation);
            self.navigationController!.pushViewController(busstopFavoritesViewController, animated: true)
        }
    }

    func goToFilter() {
        let busstopFilterViewController = BusstopFilterViewController(filteredBusLines: self.filteredBusLines, nibName: "BusstopFilterViewController", bundle: nil)
        self.navigationController!.pushViewController(busstopFilterViewController, animated: true)
    }

    func setBusStation(_ busStation: BusStationItem) {
        self.selectedBusStation = busStation
        self.autoCompleteTableView.isHidden = false
        self.searchBar.text = self.selectedBusStation?.getDescription()
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.departures = []
        self.filteredDepartures = []
        self.tableView.reloadData()

        self.getDepartures()
    }

    func setSearchDate() {
        self.navigationItem.rightBarButtonItem = nil
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        self.searchDate = self.datePicker.date
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
        self.timeField.text = dateFormatter.string(from: self.searchDate as Date)
        self.timeField.endEditing(true)
    }
}
