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

class BusstopViewController: DepartureViewController, UITabBarDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    private var selectedBusStation: BusStationItem?
    @IBOutlet weak var autoCompleteTableView: UITableView!
    private let busStations: [BusStationItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]
    private var foundBusStations: [BusStationItem] = []
    private var datePicker: UIDatePicker!
    private var observerAdded:Bool! = false
    
    
    init(busStation: BusStationItem?, nibName nibNameOrNil: String?, title: String?) {
        super.init(cellNibName: "DepartureBusstopTableViewCell", nibName: nibNameOrNil, title: title)
        self.selectedBusStation = busStation
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filter = true
        self.observerAdded = false
        self.view.backgroundColor = Theme.colorDarkGrey
        self.searchBar.barTintColor = Theme.colorDarkGrey
        self.searchBar.tintColor = Theme.colorWhite
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.setImage(UIImage(named: "ic_navigation_bus.png"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        (self.searchBar.valueForKey("searchField") as! UITextField).textColor = Theme.colorDarkGrey
        (self.searchBar.valueForKey("searchField") as! UITextField).clearButtonMode = UITextFieldViewMode.Never
        self.tabBar.tintColor = Theme.colorOrange
        self.tabBar.translucent = false
        self.tabBar.barTintColor = Theme.colorWhite
        self.tabBar.items![0].title = NSLocalizedString("GPS", comment: "")
        self.tabBar.items![1].title = NSLocalizedString("Map", comment: "")
        self.tabBar.items![2].title = NSLocalizedString("Favorites", comment: "")
        self.datePicker = UIDatePicker(frame: CGRect.zero)
        self.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
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
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setupBusstopSearchDate()
        self.autoCompleteTableView.hidden = true
        self.tabBar.selectedItem = nil
        
        if self.selectedBusStation == nil {
            self.setBusStationFromCurrentLocation()
        }
        if self.observerAdded == false {
            self.observerAdded = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector:"setBusStationFromCurrentLocation", name:
                UIApplicationWillEnterForegroundNotification, object: nil)
        }
    }
    
    func setBusStationFromCurrentLocation() {
        if UserDefaultHelper.instance.isBeaconStationDetectionEnabled() {
            let currentBusStop = UserDefaultHelper.instance.getCurrentBusStop()
            if currentBusStop != nil {
                LogHelper.instance.log(currentBusStop)
                let busStation = (SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]).find({$0.getBusStops().filter({$0.getNumber() == currentBusStop}).count > 0})
                if busStation != nil {
                    self.setBusStation(busStation!)
                    self.setupBusstopSearchDate()
                    self.autoCompleteTableView.hidden = true
                    self.tabBar.selectedItem = nil
                }
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.observerAdded = false
    }
    
    private func setupAutoCompleteTableView() {
        self.autoCompleteTableView!.hidden = true
        self.updateFoundBusStations("")
        self.view.addSubview(self.autoCompleteTableView!)
        self.autoCompleteTableView!.registerNib(UINib(nibName: "BusstopAutocompleteTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopAutocompleteTableViewCell");
    }
    
    func setupBusstopSearchDate() {
        super.setupSearchDate()
        self.datePicker.date = self.searchDate
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.timeField.text = dateFormatter.stringFromDate(self.searchDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var count = 0
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            count = self.foundBusStations.count
        } else {
            count = super.tableView(tableView, numberOfRowsInSection: section)
        }
        return count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            let busStation = self.foundBusStations[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("BusstopAutocompleteTableViewCell", forIndexPath: indexPath) as! BusstopAutocompleteTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.busStationLabel.text = busStation.getDescription()
            return cell;
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            self.setBusStation(self.foundBusStations[indexPath.row])
        } else {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
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
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (self.selectedBusStation != nil) {
            self.selectedBusStation = nil
            self.getDepartures()
        }
        self.updateFoundBusStations(searchText)
    }
    
    private func updateFoundBusStations(searchText: String) {
        self.foundBusStations = self.busStations
        if searchText != "" {
            self.foundBusStations = foundBusStations.filter({$0.getDescription().lowercaseString.containsString(searchText.lowercaseString)})
        }
        self.foundBusStations = foundBusStations.sort({$0.getDescription() < $1.getDescription()})
        self.autoCompleteTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return !self.working
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "searchBarCancel")
        searchBar.text = ""
        self.updateFoundBusStations(searchBar.text!)
        self.autoCompleteTableView.hidden = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        let activeLines = self.filteredBusLines.filter({$0.isActive()})
        if self.filter {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.filterImage, style: UIBarButtonItemStyle.Plain, target: self, action: "goToFilter")
            self.navigationItem.rightBarButtonItem!.accessibilityLabel = NSLocalizedString("Linefilter", comment: "")
            if activeLines.count != self.filteredBusLines.count {
                self.navigationItem.rightBarButtonItem?.image = self.filterImageFilled
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        self.foundBusStations = []
        self.autoCompleteTableView.hidden = true
    }
    
    func searchBarCancel() {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
    }
    
    func goToFilter() {
        let busstopFilterViewController = BusstopFilterViewController(filteredBusLines: self.filteredBusLines, nibName: "BusstopFilterViewController", bundle: nil)
        self.navigationController!.pushViewController(busstopFilterViewController, animated: true)
    }
    
    func setBusStation(busStation: BusStationItem) {
        self.selectedBusStation = busStation
        self.autoCompleteTableView.hidden = false
        self.searchBar.text = self.selectedBusStation?.getDescription()
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.departures = []
        self.filteredDepartures = []
        self.tableView.reloadData()
        self.getDepartures()
    }
    
    override internal func checkIfBusStopIsSuitable(busTripStopTime: BusTripBusStopTime, index: Int, delayStopFoundIndex: Int, delaySecondsRoundedToMin: Int, secondsFromMidnight: Int, positionItem: PositionItem?) -> Bool {
        var suitable = false
        var delay = 0
        if (index >= delayStopFoundIndex) {
            delay = delaySecondsRoundedToMin
        }
        if (self.selectedBusStation!.containsBusStop(busTripStopTime.getBusStop())
            && busTripStopTime.getSeconds() + delay >= secondsFromMidnight) {
                suitable = true
        }
        return suitable
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let datePickerDoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: "setSearchDate")
        self.navigationItem.rightBarButtonItem = datePickerDoneButton
    }
    
    func textField(textField: UITextField, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.navigationItem.rightBarButtonItem = nil
        self.departures = []
        self.filteredDepartures = []
        self.tableView.reloadData()
        self.getDepartures()
        textField.resignFirstResponder()
    }
    
    func setSearchDate() {
        self.navigationItem.rightBarButtonItem = nil
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY HH:mm"
        self.searchDate = self.datePicker.date
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
        self.timeField.text = dateFormatter.stringFromDate(self.searchDate)
        self.timeField.endEditing(true)
    }
    
    override internal func getBusLineVariantTripsAndIdentifiers(secondsFromMidnight: Int) -> BusLineVariantTripResult {
        let busLineVariantTripResult: BusLineVariantTripResult = BusLineVariantTripResult()
        if self.selectedBusStation != nil {
            let busDayType = (SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusDayTypeList) as [BusDayTypeItem]).find({NSCalendar.currentCalendar().compareDate($0.getDate(), toDate: self.searchDate, toUnitGranularity: NSCalendarUnit.Day) == NSComparisonResult.OrderedSame})
            if busDayType != nil {
                let lookBack = 60 * 60 * 2
                for busLine in self.selectedBusStation!.getBusLines() {
                    let busDayTimeTrips: [BusDayTypeTripItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusDayTypeTrip(busLine, dayType: busDayType!)) as [BusDayTypeTripItem]
                    for busDayTimeTrip in busDayTimeTrips {
                        for busTripVariant in busDayTimeTrip.getBusTripVariants() {
                            for busTrip in busTripVariant.getTrips() {
                                if busTrip.getStartTime() > secondsFromMidnight - lookBack {
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.track("NextBus")
    }
    
    override func leftDrawerButtonPress(sender: AnyObject?) {
        self.searchBar.endEditing(true)
        self.timeField.endEditing(true)
        super.leftDrawerButtonPress(sender)
    }
    
    override internal func disableSearching() {
        self.working = true
        (self.searchBar.valueForKey("searchField") as! UITextField).textColor = Theme.colorGrey
        self.timeField.userInteractionEnabled = false
        self.searchBar.alpha = 0.7
        self.timeField.alpha = 0.7
        let items = self.tabBar.items
        for item in items! {
            item.enabled = false
        }
        self.tabBar.setItems(items, animated: false)
    }
    
    override internal func enableSearching() {
        self.working = false
        (self.searchBar.valueForKey("searchField") as! UITextField).textColor = Theme.colorDarkGrey
        self.timeField.userInteractionEnabled = true
        self.searchBar.alpha = 1.0
        self.timeField.alpha = 1.0
        let items = self.tabBar.items
        for item in items! {
            item.enabled = true
        }
        self.tabBar.setItems(items, animated: false)
    }
}
