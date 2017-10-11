//
// BusStopGpsViewController.swift
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
import CoreLocation
import RealmSwift

class BusStopGpsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var busStopLabel: UILabel!
    @IBOutlet weak var tableView: MasterTableView!

    var busStop: BBusStop!
    var nearbyBusStops: [BusStopDistance]! = []

    var locationManager: CLLocationManager?

    var realm = Realm.busStops()


    init() {
        super.init(nibName: "BusStopGpsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Departures.Gps.title

        tableView.register(UINib(nibName: "BusStopGpsViewController", bundle: nil), forCellReuseIdentifier: "BusStopGpsViewController")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        locationManager = CLLocationManager()

        view.backgroundColor = Theme.darkGrey
        busStopLabel.textColor = Theme.white

        if busStop != nil {
            busStopLabel.text = busStop.name()
        } else {
            busStopLabel.text = L10n.Departures.Gps.header
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        locationManager!.stopUpdatingLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        locationManager!.requestAlwaysAuthorization()
        locationManager!.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager!.startUpdatingLocation()
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else {
            Log.warning("No recent location available")
            return
        }
        
        nearbyBusStops = BusStopRealmHelper.nearestBusStops(location: currentLocation)

        tableView.reloadData()
        locationManager?.stopUpdatingLocation()
    }
}

extension BusStopGpsViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyBusStops.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let distance = nearbyBusStops[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusStopGpsTableViewCell", for: indexPath) as! BusStopGpsTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.stationLabel.text = distance.busStop.name()
        cell.distanceLabel.text = Int(round(distance.distance)).description + "m"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let distance = nearbyBusStops[indexPath.row]

        let busStopViewController = navigationController?.viewControllers[(navigationController?
                .viewControllers.index(of: self))! - 1] as! BusStopViewController

        busStopViewController.setBusStop(distance.busStop)
        self.navigationController?.popViewController(animated: true)
    }
}
