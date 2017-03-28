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

    var dateTimePicker: UIDatePicker!
    var selectedBusLine: Line?

    var busLines: [Line] = SasaDataHelper.getData(SasaDataHelper.REC_LID) as [Line]
    var foundBusLines: [Line]! = []

    var selectedTab: String = "ALL"
    var tabId: Int = 0

    var linePickerDataSource: [Line] = []

    let dateFormatter: DateFormatter = DateFormatter()


    init(title: String?) {
        super.init(cellNibName: "DepartureBuslineTableViewCell", nibName: "LineViewController", title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.darkGrey
        self.searchBar.barTintColor = Theme.darkGrey
        self.searchBar.tintColor = Theme.white

        (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.darkGrey
        (self.searchBar.value(forKey: "searchField") as! UITextField).clearButtonMode = UITextFieldViewMode.never

        self.searchBar.backgroundImage = UIImage()
        self.searchBar.setImage(UIImage(named: "ic_navigation_bus.png"), for: UISearchBarIcon.search, state: UIControlState())
        self.tabBar.tintColor = Theme.orange
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = Theme.white
        self.tabBar.selectedItem = self.tabBar.items![0]

        var tabBarItems = tabBar.items!

        tabBarItems[0].title = NSLocalizedString("All", comment: "")
        tabBarItems[1].title = NSLocalizedString("Bozen", comment: "")
        tabBarItems[2].title = NSLocalizedString("Meran", comment: "")
        tabBarItems[3].title = NSLocalizedString("Others", comment: "")

        self.setupAutoCompleteTableView()
        self.setUpDateTime()

        loadBusLines()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.setUpDateTime()
        self.autoCompleteTableView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("BusSchedules")
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0

        if self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView) {
            count = self.foundBusLines.count
        } else {
            count = super.tableView(tableView, numberOfRowsInSection: section)
        }

        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView) {
            let busLine: Line = self.foundBusLines[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusLineAutoCompleteTableViewCell",
                    for: indexPath) as! BusLineAutoCompleteTableViewCell

            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.busLineLabel.text = busLine.name

            return cell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView) {
            self.setBusLine(self.foundBusLines[indexPath.row])
        } else {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }


    override internal func disableSearching() {
        self.working = true
        (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.grey

        self.dateTimeTextField.isUserInteractionEnabled = false
        self.searchBar.alpha = 0.7
        self.dateTimeTextField.alpha = 0.7

        let items = self.tabBar.items
        for item in items! {
            item.isEnabled = false
        }

        self.tabBar.setItems(items, animated: false)
    }

    override internal func enableSearching() {
        if self.working == true {
            self.working = false
            (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.darkGrey
            self.dateTimeTextField.isUserInteractionEnabled = true
            self.searchBar.alpha = 1.0
            self.dateTimeTextField.alpha = 1.0

            let items = self.tabBar.items
            for item in items! {
                item.isEnabled = true
            }

            self.tabBar.setItems(items, animated: false)
        }
    }


    func setupAutoCompleteTableView() {
        self.autoCompleteTableView!.isHidden = true
        self.updateFoundBusLines("")
        self.view.addSubview(self.autoCompleteTableView!)

        self.autoCompleteTableView!.register(UINib(nibName: "BusLineAutoCompleteTableViewCell", bundle: nil),
                forCellReuseIdentifier: "BusLineAutoCompleteTableViewCell")
    }

    func resetLinePickerDataSource() {
        self.linePickerDataSource = []
        let defaultItem = Line(shortName: NSLocalizedString("Select ...", comment: ""),
                name: NSLocalizedString("Select ...", comment: ""), variants: [0], number: 0)

        self.linePickerDataSource.append(defaultItem)
    }

    func setUpDateTime() {
        self.dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.dateTimePicker = UIDatePicker(frame: CGRect.zero)
        self.dateTimePicker.datePickerMode = UIDatePickerMode.dateAndTime
        self.dateTimePicker.backgroundColor = Theme.darkGrey
        self.dateTimePicker.tintColor = Theme.white
        self.dateTimePicker.setValue(Theme.white, forKey: "textColor")
        self.dateTimeTextField.delegate = self
        self.dateTimeTextField.tag = 2
        self.dateTimeTextField.textColor = Theme.white
        self.dateTimeTextField.tintColor = Theme.transparent
        self.dateTimeTextField.text = self.dateFormatter.string(from: self.searchDate as Date)
        self.dateTimeTextField.inputView = self.dateTimePicker
    }


    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if self.tabId != item.tag {
            self.selectedBusLine = nil
            self.getDepartures()
        }

        self.tabId = item.tag

        switch self.tabId {
        case 1:
            self.selectedTab = "BZ"
        case 2:
            self.selectedTab = "ME"
        case 3:
            self.selectedTab = "OTHER"
        default:
            self.selectedTab = "ALL"
        }

        self.loadBusLines()
        self.searchBar.becomeFirstResponder()
    }


    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                target: self, action: #selector(LineViewController.searchBarCancel))

        searchBar.text = ""
        self.updateFoundBusLines(searchBar.text!)
        self.autoCompleteTableView.isHidden = false
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.selectedBusLine != nil {
            self.selectedBusLine = nil
            self.getDepartures()
        }

        self.updateFoundBusLines(searchText)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return !self.working
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = nil
        self.foundBusLines = []
        self.autoCompleteTableView.isHidden = true
    }

    func searchBarCancel() {
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
    }


    override internal func getBusLineVariantTripsAndIdentifiers(_ secondsFromMidnight: Int) -> BusLineVariantTripResult {
        let busLineVariantTripResult: BusLineVariantTripResult = BusLineVariantTripResult()

        if self.selectedBusLine != nil {
            let busDayType = (SasaDataHelper.getData(SasaDataHelper.FIRMENKALENDER) as [BusDayTypeItem])
                    .find({ (Calendar.current as NSCalendar)
                    .compare($0.date, to: self.searchDate, toUnitGranularity: NSCalendar.Unit.day) == ComparisonResult.orderedSame })

            let lookBack = 60 * 60 * 2

            let busDayTimeTrips = SasaDataHelper.getData(SasaDataHelper
                    .BusDayTypeTrip(self.selectedBusLine!, dayType: busDayType!)) as [BusDayTypeTripItem]

            for busDayTimeTrip in busDayTimeTrips {
                for busTripVariant in busDayTimeTrip.busTripVariants {
                    for busTrip in busTripVariant.trips {
                        if busTrip.startTime > secondsFromMidnight - lookBack {
                            busLineVariantTripResult.addBusLineVariantTrip(BusLineVariantTrip(busLine:
                            self.selectedBusLine!, variant: busTripVariant, trip: busTrip))
                        }
                    }
                }
            }
        }

        return busLineVariantTripResult
    }

    override internal func checkIfBusStopIsSuitable(_ stopTime: BusTripBusStopTime, index: Int, delayStopFoundIndex: Int,
                                                    delay: Int, secondsFromMidnight: Int, realtimeBus: RealtimeBus?) -> Bool {
        var suitable = false

        if (realtimeBus != nil && realtimeBus!.locationNumber == stopTime.busStop) ||
                   (realtimeBus == nil && stopTime.seconds >= self.secondsFromMidnight) {

            suitable = true
        }

        return suitable
    }

    override func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.searchBar.endEditing(true)
        self.dateTimeTextField.endEditing(true)
        super.leftDrawerButtonPress(sender)
    }


    func updateFoundBusLines(_ searchText: String) {
        self.foundBusLines = self.busLines
        if searchText != "" {
            self.foundBusLines = busLines.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        }
        self.autoCompleteTableView.reloadData()
    }

    func loadBusLines() {
        Log.info("Loading bus lines for zone \(selectedTab)")

        var busLines = SasaDataHelper.getData(SasaDataHelper.REC_LID) as [Line]

        if selectedTab != "ALL" {
            busLines = busLines.filter({ $0.getArea() == selectedTab })
        }

        self.busLines = busLines.sorted(by: { $0.id < $1.id })
        self.tableView.reloadData()
        self.updateFoundBusLines("")
    }


    func setBusLine(_ busLine: Line) {
        self.selectedBusLine = busLine
        self.autoCompleteTableView.isHidden = false
        self.searchBar.text = self.selectedBusLine!.name
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.departures = []
        self.filteredDepartures = []
        self.tableView.reloadData()
        self.getDepartures()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePickerDoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItemStyle.done, target: self, action: #selector(LineViewController.endDateEditing(_:)))

        self.navigationItem.rightBarButtonItem = datePickerDoneButton
    }

    func endDateEditing(_ sender: UIBarButtonItem) {
        self.searchDate = self.dateTimePicker.date
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
        self.dateTimeTextField.text = self.dateFormatter.string(from: self.searchDate as Date)
        self.dateTimeTextField.endEditing(true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
}
