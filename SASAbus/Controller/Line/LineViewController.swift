//
// LineViewController.swift
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

class LineViewController: DepartureViewController, UITextFieldDelegate, UITabBarDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var dateTimeTextField: UITextField!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    private var dateTimePicker: UIDatePicker!
    private var selectedBusLine: BusLineItem?
    private var busLines: [BusLineItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusLines) as [BusLineItem]
    private var tabId: Int!
    private var foundBusLines: [BusLineItem]! = []
    
    init(nibName nibNameOrNil: String?, title: String?) {
        super.init(cellNibName: "DepartureBuslineTableViewCell", nibName: nibNameOrNil, title: title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var linePickerDataSource: [BusLineItem] = []
    let dateFormatter: NSDateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.colorDarkGrey
        self.searchBar.barTintColor = Theme.colorDarkGrey
        self.searchBar.tintColor = Theme.colorWhite
        (self.searchBar.valueForKey("searchField") as! UITextField).textColor = Theme.colorDarkGrey
        (self.searchBar.valueForKey("searchField") as! UITextField).clearButtonMode = UITextFieldViewMode.Never
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.setImage(UIImage(named: "ic_navigation_bus.png"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        self.tabBar.tintColor = Theme.colorOrange
        self.tabBar.translucent = false
        self.tabBar.backgroundColor = Theme.colorWhite
        self.tabBar.selectedItem = self.tabBar.items![0]
        self.tabId = self.tabBar.selectedItem!.tag
        var tabBarItems = tabBar.items!
        tabBarItems[0].title = NSLocalizedString("All", comment: "")
        tabBarItems[1].title = NSLocalizedString("Bozen", comment: "")
        tabBarItems[2].title = NSLocalizedString("Meran", comment: "")
        tabBarItems[3].title = NSLocalizedString("Others", comment: "")
        self.setupAutoCompleteTableView()
        self.setUpDateTime()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.setUpDateTime()
        self.autoCompleteTableView.hidden = true
    }
    
    private func setupAutoCompleteTableView() {
        self.autoCompleteTableView!.hidden = true
        self.updateFoundBusLines("")
        self.view.addSubview(self.autoCompleteTableView!)
        self.autoCompleteTableView!.registerNib(UINib(nibName: "BuslineAutocompleteTableViewCell", bundle: nil), forCellReuseIdentifier: "BuslineAutocompleteTableViewCell");
    }
    
    private func resetLinePickerDataSource() {
        self.linePickerDataSource = []
        let defaultItem = BusLineItem(shortName: NSLocalizedString("Select ...", comment: ""), name: NSLocalizedString("Select ...", comment: ""), variants: [0], number: 0)
        self.linePickerDataSource.append(defaultItem!)
    }
    
    private func setUpDateTime() {
        self.dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.dateTimePicker = UIDatePicker(frame: CGRect.zero)
        self.dateTimePicker.datePickerMode = UIDatePickerMode.DateAndTime
        self.dateTimePicker.backgroundColor = Theme.colorDarkGrey
        self.dateTimePicker.tintColor = Theme.colorWhite
        self.dateTimePicker.setValue(Theme.colorWhite, forKey: "textColor")
        self.dateTimeTextField.delegate = self
        self.dateTimeTextField.tag = 2
        self.dateTimeTextField.textColor = Theme.colorWhite
        self.dateTimeTextField.tintColor = Theme.colorTransparent
        self.dateTimeTextField.text = self.dateFormatter.stringFromDate(self.searchDate)
        self.dateTimeTextField.inputView = self.dateTimePicker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if self.tabId != item.tag {
            self.selectedBusLine = nil
            self.getDepartures()
        }
        self.tabId = item.tag
        self.loadBusLines()
        self.searchBar.becomeFirstResponder()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var count = 0
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            count = self.foundBusLines.count
        } else {
            count = super.tableView(tableView, numberOfRowsInSection: section)
        }
        return count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            let busLine = self.foundBusLines[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("BuslineAutocompleteTableViewCell", forIndexPath: indexPath) as! BuslineAutocompleteTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.busLineLabel.text = busLine.getShortName()
            return cell;
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView)) {
            self.setBusLine(self.foundBusLines[indexPath.row])
        } else {
            super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "searchBarCancel")
        searchBar.text = ""
        self.updateFoundBusLines(searchBar.text!)
        self.autoCompleteTableView.hidden = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (self.selectedBusLine != nil) {
            self.selectedBusLine = nil
            self.getDepartures()
        }
        self.updateFoundBusLines(searchText)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return !self.working
    }
    
    private func updateFoundBusLines(searchText: String) {
        self.foundBusLines = self.busLines
        if searchText != "" {
            self.foundBusLines = busLines.filter({$0.getShortName().lowercaseString.containsString(searchText.lowercaseString)})
        }
        self.autoCompleteTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = nil
        self.foundBusLines = []
        self.autoCompleteTableView.hidden = true
    }
    
    func searchBarCancel() {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
    }
    
    func setBusLine(busLine: BusLineItem) {
        self.selectedBusLine = busLine
        self.autoCompleteTableView.hidden = false
        self.searchBar.text = self.selectedBusLine!.getShortName()
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.departures = []
        self.filteredDepartures = []
        self.tableView.reloadData()
        self.getDepartures()
    }
    
    private func loadBusLines() {
        var busLines = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusLines) as [BusLineItem]
        var filter: String? = nil
        switch self.tabId {
        case 1:
            filter = "BZ"
            break
        case 2:
            filter = "ME"
            break
        case 3:
            filter = "OTHER"
            break
        default:
            break
        }
        if filter != nil {
            busLines = busLines.filter({$0.getArea() == filter})
        }
        self.busLines = busLines.sort({$0.getShortName() < $1.getShortName()})
        self.updateFoundBusLines("")
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let datePickerDoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.Done, target: self, action: "endDateEditing:")
        self.navigationItem.rightBarButtonItem = datePickerDoneButton
    }
    
    func endDateEditing(sender: UIBarButtonItem) {
        self.searchDate = self.dateTimePicker.date
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
        self.dateTimeTextField.text = self.dateFormatter.stringFromDate(self.searchDate)
        self.dateTimeTextField.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.track("BusSchedules")
    }
    
    override internal func getBusLineVariantTripsAndIdentifiers(secondsFromMidnight: Int) -> BusLineVariantTripResult {
        let busLineVariantTripResult: BusLineVariantTripResult = BusLineVariantTripResult()
        if self.selectedBusLine != nil {
            let busDayType = (SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusDayTypeList) as [BusDayTypeItem]).find({NSCalendar.currentCalendar().compareDate($0.getDate(), toDate: self.searchDate, toUnitGranularity: NSCalendarUnit.Day) == NSComparisonResult.OrderedSame})
            let lookBack = 60 * 60 * 2
            let busDayTimeTrips: [BusDayTypeTripItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusDayTypeTrip(self.selectedBusLine!, dayType: busDayType!)) as [BusDayTypeTripItem]
            for busDayTimeTrip in busDayTimeTrips {
                for busTripVariant in busDayTimeTrip.getBusTripVariants() {
                    for busTrip in busTripVariant.getTrips() {
                        if (busTrip.getStartTime() > secondsFromMidnight - lookBack) {
                            busLineVariantTripResult.addBusLineVariantTrip(BusLineVariantTrip(busLine: self.selectedBusLine!, variant: busTripVariant, trip: busTrip))
                        }
                    }
                }
            }
        }
        return busLineVariantTripResult
    }
    
    override internal func checkIfBusStopIsSuitable(busTripStopTime: BusTripBusStopTime, index: Int, delayStopFoundIndex: Int, delaySecondsRoundedToMin: Int, secondsFromMidnight: Int, positionItem: PositionItem?) -> Bool {
        var suitable = false
        if (positionItem != nil && positionItem!.getLocationNumber() == busTripStopTime.getBusStop()) || (positionItem == nil && busTripStopTime.getSeconds() >= self.secondsFromMidnight) {
            suitable = true
        }
        return suitable
    }
    
    override func leftDrawerButtonPress(sender: AnyObject?) {
        self.searchBar.endEditing(true)
        self.dateTimeTextField.endEditing(true)
        super.leftDrawerButtonPress(sender)
    }
    
    override internal func disableSearching() {
        self.working = true
        (self.searchBar.valueForKey("searchField") as! UITextField).textColor = Theme.colorGrey
        self.dateTimeTextField.userInteractionEnabled = false
        self.searchBar.alpha = 0.7
        self.dateTimeTextField.alpha = 0.7
        let items = self.tabBar.items
        for item in items! {
            item.enabled = false
        }
        self.tabBar.setItems(items, animated: false)
    }
    
    override internal func enableSearching() {
        if self.working == true {
            self.working = false
            (self.searchBar.valueForKey("searchField") as! UITextField).textColor = Theme.colorDarkGrey
            self.dateTimeTextField.userInteractionEnabled = true
            self.searchBar.alpha = 1.0
            self.dateTimeTextField.alpha = 1.0
            let items = self.tabBar.items
            for item in items! {
                item.enabled = true
            }
            self.tabBar.setItems(items, animated: false)
        }
    }
}
