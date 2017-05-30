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
import RealmSwift
import Realm
import RxSwift
import RxCocoa

class BusStopViewController: MasterViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate,
        UISearchBarDelegate, UITextFieldDelegate {

    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var autoCompleteTableView: UITableView!

    @IBOutlet weak var tableView: MasterTableView!

    var selectedBusStop: BBusStop?
    var foundBusStations: [BBusStop] = []
    var datePicker: UIDatePicker!
    var observerAdded: Bool! = false


    var filterImage = UIImage(named: "filter_icon.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    var filterImageFilled = UIImage(named: "filter_icon_filled.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

    var departures: [Departure] = []

    var searchDate: Date!
    var secondsFromMidnight: Int!
    var filteredBusLines: [BusLineFilter] = []
    var filter = false
    var refreshControl: UIRefreshControl!

    var working: Bool! = false

    var realm = Realm.busStops()


    init(busStop: BBusStop?, title: String?) {
        super.init(nibName: "BusStopViewController", title: title)

        self.selectedBusStop = busStop
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

        tableView.register(UINib(nibName: "DepartureBusStopTableViewCell", bundle: nil),
                forCellReuseIdentifier: "DepartureTableViewCell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.lightOrange
        refreshControl.addTarget(self, action: #selector(parseData), for: UIControlEvents.valueChanged)

        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])

        tableView.addSubview(refreshControl)

        setupSearchDate()

        filter = true
        observerAdded = false
        view.backgroundColor = Theme.darkGrey

        searchBar.barTintColor = Theme.darkGrey
        searchBar.tintColor = Theme.white
        searchBar.backgroundImage = UIImage()
        searchBar.setImage(UIImage(named: "ic_navigation_bus.png"), for: UISearchBarIcon.search, state: UIControlState())

        (searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.darkGrey
        (searchBar.value(forKey: "searchField") as! UITextField).clearButtonMode = UITextFieldViewMode.never

        tabBar.tintColor = Theme.orange
        tabBar.isTranslucent = false
        tabBar.barTintColor = Theme.white

        tabBar.items![0].title = NSLocalizedString("GPS", comment: "")
        tabBar.items![1].title = NSLocalizedString("Map", comment: "")
        tabBar.items![2].title = NSLocalizedString("Favorites", comment: "")

        datePicker = UIDatePicker(frame: CGRect.zero)
        datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        datePicker.backgroundColor = Theme.darkGrey
        datePicker.tintColor = Theme.white
        datePicker.setValue(Theme.white, forKey: "textColor")

        timeField.textColor = Theme.white
        timeField.tintColor = Theme.transparent
        timeField.inputView = datePicker

        setupAutoCompleteTableView()

        if selectedBusStop != nil {
            setupBusStopSearchDate()
            setBusStop(selectedBusStop!)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.setupBusStopSearchDate()
        self.autoCompleteTableView.isHidden = true
        self.tabBar.selectedItem = nil

        if self.selectedBusStop == nil {
            self.setBusStationFromCurrentLocation()
        }

        if self.observerAdded == false {
            self.observerAdded = true
            NotificationCenter.default.addObserver(self, selector: #selector(setBusStationFromCurrentLocation), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("NextBus")
    }


    override func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.searchBar.endEditing(true)
        self.timeField.endEditing(true)
        super.leftDrawerButtonPress(sender)
    }

    internal func disableSearching() {
        self.working = true

        (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.grey

        self.timeField.isUserInteractionEnabled = false
        self.searchBar.alpha = 0.7
        self.timeField.alpha = 0.7

        let items = self.tabBar.items

        for item in items! {
            item.isEnabled = false
        }

        self.tabBar.setItems(items, animated: false)
    }

    internal func enableSearching() {
        self.working = false

        (self.searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.darkGrey

        self.timeField.isUserInteractionEnabled = true
        self.searchBar.alpha = 1.0
        self.timeField.alpha = 1.0

        let items = self.tabBar.items

        for item in items! {
            item.isEnabled = true
        }

        self.tabBar.setItems(items, animated: false)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0

        if self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView) {
            count = self.foundBusStations.count
        } else {
            count = departures.count
        }

        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView) {
            let busStation = self.foundBusStations[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "BusStopAutoCompleteTableViewCell",
                    for: indexPath) as! BusStopAutoCompleteTableViewCell

            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.busStationLabel.text = busStation.name()

            return cell
        } else {
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

            cell.infoLabel.text = departure.line
            cell.directionLabel.text = departure.destination

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if autoCompleteTableView != nil && tableView.isEqual(autoCompleteTableView) {
            setBusStop(foundBusStations[indexPath.row])
        } else {
            let busStopTripViewController = BusStopTripViewController(departure: departures[indexPath.row])
            self.navigationController!.pushViewController(busStopTripViewController, animated: true)
        }
    }


    fileprivate func setupAutoCompleteTableView() {
        self.autoCompleteTableView!.isHidden = true
        self.updateFoundBusStations("")
        self.view.addSubview(self.autoCompleteTableView!)

        self.autoCompleteTableView!.register(UINib(nibName: "BusStopAutoCompleteTableViewCell", bundle: nil),
                forCellReuseIdentifier: "BusStopAutoCompleteTableViewCell")
    }

    fileprivate func updateFoundBusStations(_ searchText: String) {
        let busStops: Results<BusStop>

        if searchText.isEmpty {
            busStops = realm.objects(BusStop.self)
        } else {
            busStops = realm.objects(BusStop.self)
                    .filter("nameDe CONTAINS[c] '\(searchText)' OR nameIt CONTAINS[c] '\(searchText)'")
        }

        let mapped = busStops.map {
            BBusStop(fromRealm: $0)
        }

        foundBusStations = Array(Set(mapped))

        self.foundBusStations = foundBusStations.sorted(by: {
            $0.name(locale: Utils.locale()) < $1.name(locale: Utils.locale())
        })

        self.autoCompleteTableView.reloadData()
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.selectedBusStop != nil {
            self.selectedBusStop = nil
            self.getDepartures()
        }

        self.updateFoundBusStations(searchText)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return !self.working
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                target: self, action: #selector(BusStopViewController.searchBarCancel))

        searchBar.text = ""
        self.updateFoundBusStations(searchBar.text!)
        self.autoCompleteTableView.isHidden = false
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let activeLines = self.filteredBusLines.filter({ $0.active })

        if self.filter {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: self.filterImage,
                    style: UIBarButtonItemStyle.plain, target: self, action: #selector(BusStopViewController.goToFilter))

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
        let datePickerDoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItemStyle.done, target: self, action: #selector(BusStopViewController.setSearchDate))

        self.navigationItem.rightBarButtonItem = datePickerDoneButton
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

    func setupSearchDate() {
        self.searchDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.secondsFromMidnight = self.getSecondsFromMidnight(self.searchDate)
    }


    func textField(_ textField: UITextField, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem = nil
        self.departures = []
        self.tableView.reloadData()
        self.getDepartures()

        textField.resignFirstResponder()
    }


    func setBusStationFromCurrentLocation() {
        if UserDefaultHelper.instance.isBeaconStationDetectionEnabled() {
            let currentBusStop = UserDefaultHelper.instance.getCurrentBusStop()

            if currentBusStop != nil {
                Log.info("Current bus stop: \(currentBusStop)")

                if let busStop = realm.objects(BusStop.self).filter("id == \(currentBusStop)").first {
                    self.setBusStop(BBusStop(fromRealm: busStop))

                    self.setupBusStopSearchDate()
                    self.autoCompleteTableView.isHidden = true
                    self.tabBar.selectedItem = nil
                }
            }
        }
    }

    func setupBusStopSearchDate() {
        setupSearchDate()

        self.datePicker.date = self.searchDate as Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        self.timeField.text = dateFormatter.string(from: self.searchDate as Date)
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            let busStopGpsViewController = BusStopGpsViewController()
            self.navigationController!.pushViewController(busStopGpsViewController, animated: true)
        } else if item.tag == 1 {
            let busStopMapViewController = BusStopMapViewController()
            self.navigationController!.pushViewController(busStopMapViewController, animated: true)
        } else if item.tag == 2 {
            let busStopFavoritesViewController = BusStopFavoritesViewController(busStop: self.selectedBusStop)
            self.navigationController!.pushViewController(busStopFavoritesViewController, animated: true)
        }
    }

    func goToFilter() {
        let busStopFilterViewController = BusStopFilterViewController(filteredBusLines: self.filteredBusLines)
        self.navigationController!.pushViewController(busStopFilterViewController, animated: true)
    }

    func setBusStop(_ busStop: BBusStop) {
        self.selectedBusStop = busStop
        self.autoCompleteTableView.isHidden = false
        self.searchBar.text = self.selectedBusStop?.name()
        self.searchBar.endEditing(true)
        self.searchBar.resignFirstResponder()
        self.departures = []
        self.tableView.reloadData()

        parseData()
    }


    func parseData() {
        _ = self.getDepartures()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { items in
                    self.departures = items
                    self.tableView.reloadData()

                    // TODO load real time delay data
                }, onError: { error in
                    Log.error("Could not fetch departures: \(error)")
                })
    }

    func getDepartures() -> Observable<[Departure]> {
        return Observable.create { observer in
            let departures = DepartureMonitor()
                    .atBusStopFamily(family: self.selectedBusStop?.family ?? 0)
                    .at(date: Date())
                    .collect()

            let mapped = departures.map {
                $0.asDeparture(busStopId: self.selectedBusStop?.id ?? 0)
            }

            Log.error("Departures: \(mapped)")

            observer.on(.next(mapped))

            return Disposables.create()
        }
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

    func getSecondsFromMidnight(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents(
                [Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second], from: date)

        return (components.hour! * 60 + components.minute!) * 60
    }
}
