//
// BusStopViewController.swift
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
// along with SASAbus. If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

import RxSwift
import RxCocoa

import Realm
import RealmSwift

import Alamofire
import StatefulViewController

class BusStopViewController: MasterViewController, UITabBarDelegate, StatefulViewController {

    let dateFormat = "HH:mm"

    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabBar: UITabBar!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var autoCompleteTableView: UITableView!

    var selectedBusStop: BBusStop?
    var foundBusStations: [BBusStop] = []
    var datePicker: UIDatePicker!

    var allDepartures: [Departure] = []
    var disabledDepartures: [Departure] = []

    var searchDate: Date!
    var refreshControl: UIRefreshControl!

    var working: Bool! = false

    var realm = Realm.busStops()


    init(busStop: BBusStop? = nil) {
        super.init(nibName: "BusStopViewController", title: L10n.Departures.title)

        self.selectedBusStop = busStop
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "DepartureViewCell", bundle: nil),
                forCellReuseIdentifier: "DepartureViewCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.lightOrange
        refreshControl.addTarget(self, action: #selector(parseData), for: .valueChanged)

        refreshControl.attributedTitle = NSAttributedString(
                string: L10n.General.pullToRefresh,
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey]
        )

        tableView.refreshControl = refreshControl

        setupSearchDate()

        view.backgroundColor = Theme.darkGrey

        searchBar.barTintColor = .darkGray
        searchBar.tintColor = Theme.white
        searchBar.backgroundImage = UIImage()
        searchBar.setImage(Asset.icNavigationBus.image, for: UISearchBarIcon.search, state: UIControlState())

        (searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.darkGrey
        (searchBar.value(forKey: "searchField") as! UITextField).clearButtonMode = UITextFieldViewMode.never

        navigationItem.rightBarButtonItem = getFilterButton()

        tabBar.items![0].title = L10n.Departures.Header.gps
        tabBar.items![1].title = L10n.Departures.Header.map
        tabBar.items![2].title = L10n.Departures.Header.favorites

        datePicker = UIDatePicker(frame: CGRect.zero)
        datePicker.datePickerMode = .dateAndTime
        datePicker.backgroundColor = Theme.darkGrey
        datePicker.tintColor = Theme.white
        datePicker.setValue(Theme.white, forKey: "textColor")

        timeField.textColor = Theme.white
        timeField.tintColor = Theme.transparent
        timeField.inputView = datePicker

        loadingView = LoadingView(frame: view.frame)
        emptyView = EmptyView(frame: view.frame)
        errorView = ErrorView(frame: view.frame, target: self, action: #selector(parseData))

        setupAutoCompleteTableView()

        setupBusStopSearchDate()
        
        if selectedBusStop != nil {
            setBusStop(selectedBusStop!)
        }
    }

    override func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.searchBar.endEditing(true)
        self.timeField.endEditing(true)

        super.leftDrawerButtonPress(sender)
    }


    fileprivate func setupAutoCompleteTableView() {
        self.autoCompleteTableView!.isHidden = true
        self.updateFoundBusStations("")
        self.view.addSubview(self.autoCompleteTableView!)

        self.autoCompleteTableView!.register(UINib(nibName: "DepartureAutoCompleteCell", bundle: nil),
                forCellReuseIdentifier: "DepartureAutoCompleteCell")
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


    func setBusStationFromCurrentLocation() {
        // TODO
        
        /*if UserDefaultHelper.instance.isBeaconStationDetectionEnabled() {
            let currentBusStop = UserDefaultHelper.instance.getCurrentBusStop()

            if let stop = currentBusStop != nil {
                Log.info("Current bus stop: \(stop)")

                if let busStop = realm.objects(BusStop.self).filter("id == \(stop)").first {
                    setBusStop(BBusStop(fromRealm: busStop))

                    setupBusStopSearchDate()
                    autoCompleteTableView.isHidden = true
                    tabBar.selectedItem = nil
                }
            }
        }*/
    }

    func setupBusStopSearchDate() {
        setupSearchDate()

        datePicker.date = searchDate as Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        timeField.text = dateFormatter.string(from: searchDate as Date)
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            let busStopGpsViewController = BusStopGpsViewController()
            navigationController!.pushViewController(busStopGpsViewController, animated: true)
        } else if item.tag == 1 {
            let busStopMapViewController = BusStopMapViewController()
            navigationController!.pushViewController(busStopMapViewController, animated: true)
        } else if item.tag == 2 {
            let busStopFavoritesViewController = BusStopFavoritesViewController(busStop: self.selectedBusStop)
            navigationController!.pushViewController(busStopFavoritesViewController, animated: true)
        }
    }

    func goToFilter() {
        let busStopFilterViewController = BusStopFilterViewController()
        navigationController!.pushViewController(busStopFilterViewController, animated: true)
    }

    func setBusStop(_ busStop: BBusStop) {
        if selectedBusStop != nil && selectedBusStop!.family == busStop.family {
            // Don't reload same bus stop
            return
        }

        selectedBusStop = busStop
        autoCompleteTableView.isHidden = true

        searchBar.text = selectedBusStop?.name()
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()

        allDepartures.removeAll()
        disabledDepartures.removeAll()
        tableView.reloadData()

        parseData()
    }


    func parseData() {
        guard selectedBusStop != nil else {
            Log.error("No bus stop is currently selected")
            return
        }

        startLoading()

        _ = self.getDepartures()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { items in
                    self.allDepartures.removeAll()
                    self.allDepartures.append(contentsOf: items)

                    self.updateFilter()

                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()

                    self.endLoading(animated: false)

                    self.loadDelays()
                }, onError: { error in
                    Utils.logError(error, message: "Could not fetch departures")

                    self.allDepartures.removeAll()

                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()

                    self.endLoading(animated: false, error: error)
                })
    }

    func loadDelays() {
        _ = RealtimeApi.delays()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { buses in
                    for bus in buses {
                        for item in self.allDepartures {
                            if item.trip == bus.trip {
                                item.delay = bus.delay
                                item.vehicle = bus.vehicle
                                item.currentBusStop = bus.busStop

                                break
                            }
                        }
                    }

                    self.allDepartures.filter {
                        $0.delay == Config.BUS_STOP_DETAILS_OPERATION_RUNNING
                    }.forEach {
                        $0.delay = Config.BUS_STOP_DETAILS_NO_DELAY
                    }

                    if !self.allDepartures.isEmpty {
                        self.tableView.reloadData()
                    }
                }, onError: { error in
                    Utils.logError(error, message: "Could not load delays")

                    self.allDepartures.filter {
                        $0.delay == Config.BUS_STOP_DETAILS_OPERATION_RUNNING
                    }.forEach {
                        $0.delay = Config.BUS_STOP_DETAILS_NO_DELAY
                    }

                    if !self.allDepartures.isEmpty {
                        self.tableView.reloadData()
                    }
                })
    }


    func updateFilter() {
        let disabledLines: [Int] = UserRealmHelper.getDisabledDepartures()

        disabledDepartures.removeAll()

        if disabledLines.isEmpty {
            disabledDepartures.append(contentsOf: allDepartures)
        } else {
            disabledDepartures.append(contentsOf: allDepartures.filter {
                !disabledLines.contains($0.lineId)
            })
        }

        self.refreshControl.endRefreshing()
        self.tableView.reloadData()

        self.enableSearching()
    }

    func hasContent() -> Bool {
        return !allDepartures.isEmpty
    }

    
    func getDepartures() -> Observable<[Departure]> {
        return Observable.create { observer in
            let departures = DepartureMonitor()
                .atBusStopFamily(family: self.selectedBusStop?.family ?? 0)
                .at(date: self.searchDate)
                .collect()
            
            let mapped = departures.map {
                $0.asDeparture(busStopId: self.selectedBusStop?.id ?? 0)
            }
            
            observer.on(.next(mapped))
            
            return Disposables.create()
        }
    }
}


extension BusStopViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView) {
            return self.foundBusStations.count
        } else {
            return disabledDepartures.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.autoCompleteTableView != nil && tableView.isEqual(self.autoCompleteTableView) {
            let busStation = self.foundBusStations[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureAutoCompleteCell",
                    for: indexPath) as! DepartureAutoCompleteCell

            cell.label.text = busStation.name()

            return cell
        }

        let departure = disabledDepartures[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartureViewCell", for: indexPath) as! DepartureViewCell

        cell.timeLabel.text = departure.time

        if departure.delay == Departure.OPERATION_RUNNING {
            cell.delayLabel.text = L10n.Departures.Cell.loading
            cell.delayColor = Theme.darkGrey
        } else if departure.delay == Departure.NO_DELAY {
            cell.delayLabel.text = L10n.Departures.Cell.noData
            cell.delayColor = Theme.darkGrey
        }
        
        if departure.vehicle != 0 {
            cell.delayColor = Color.delay(departure.delay)

            if departure.delay == 0 {
                cell.delayLabel.text = L10n.General.delayPunctual
            } else if departure.delay < 0 {
                cell.delayLabel.text = L10n.General.delayEarly(abs(departure.delay))
            } else {
                cell.delayLabel.text = L10n.General.delayDelayed(departure.delay)
            }
        }

        cell.infoLabel.text = Lines.line(id: departure.lineId)
        cell.directionLabel.text = departure.destination

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if autoCompleteTableView != nil && tableView.isEqual(autoCompleteTableView) {
            navigationItem.rightBarButtonItem = getFilterButton()

            setBusStop(foundBusStations[indexPath.row])
        } else {
            let item = disabledDepartures[indexPath.row]

            let busStopTripViewController = LineCourseViewController(
                    tripId: item.trip,
                    lineId: item.lineId,
                    vehicle: item.vehicle,
                    currentBusStop: item.currentBusStop,
                    busStopGroup: item.busStopGroup
            )

            self.navigationController!.pushViewController(busStopTripViewController, animated: true)
        }
    }
}

extension BusStopViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return false
    }


    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePickerDoneButton = UIBarButtonItem(
                title: L10n.Departures.Button.done,
                style: UIBarButtonItemStyle.done,
                target: self,
                action: #selector(setSearchDate)
        )

        navigationItem.rightBarButtonItem = datePickerDoneButton
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem = nil

        allDepartures.removeAll()
        tableView.reloadData()


        textField.resignFirstResponder()
    }
}

extension BusStopViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if selectedBusStop != nil {
            selectedBusStop = nil
        }

        updateFoundBusStations(searchText)
    }


    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return !working
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(searchBarCancel)
        )

        searchBar.text = ""

        updateFoundBusStations(searchBar.text!)
        autoCompleteTableView.isHidden = false
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        foundBusStations = []
        autoCompleteTableView.isHidden = true
    }
}


extension BusStopViewController {

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
        working = false

        (searchBar.value(forKey: "searchField") as! UITextField).textColor = Theme.darkGrey

        timeField.isUserInteractionEnabled = true
        searchBar.alpha = 1.0
        timeField.alpha = 1.0

        let items = tabBar.items

        for item in items! {
            item.isEnabled = true
        }

        tabBar.setItems(items, animated: false)
    }


    func searchBarCancel() {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()

        navigationItem.rightBarButtonItem = getFilterButton()
    }

    func setSearchDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat

        searchDate = datePicker.date
        
        timeField.text = dateFormatter.string(from: searchDate as Date)
        timeField.endEditing(true)

        navigationItem.rightBarButtonItem = getFilterButton()
        
        allDepartures.removeAll()
        disabledDepartures.removeAll()
        
        tableView.reloadData()
        
        parseData()
    }

    func setupSearchDate() {
        self.searchDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
    }


    func getFilterButton() -> UIBarButtonItem {
        return UIBarButtonItem(
                image: Asset.filterIcon.image.withRenderingMode(UIImageRenderingMode.alwaysTemplate),
                style: .plain,
                target: self,
                action: #selector(goToFilter)
        )
    }
}
