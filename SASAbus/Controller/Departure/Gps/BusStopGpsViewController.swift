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

    fileprivate var busStop: BusStationItem!
    fileprivate var nearbyBusStops: [BusStationDistance]! = []

    var locationManager: CLLocationManager?

    var realm = Realm.busStops()


    init() {
        super.init(nibName: "BusStopGpsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Bus stops near you", comment: "")

        tableView.register(UINib(nibName: "BusStopGpsViewController", bundle: nil), forCellReuseIdentifier: "BusStopGpsViewController")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        locationManager = CLLocationManager()

        view.backgroundColor = Theme.darkGrey
        busStopLabel.textColor = Theme.white

        if busStop != nil {
            busStopLabel.text = busStop.getDescription()
        } else {
            busStopLabel.text = NSLocalizedString("Select a nearby bus station", comment: "")
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

        let busStations = realm.objects(BusStop.self)
        var nearbyBusStations: [BusStationDistance] = []

        for busStop in busStations {
            var busStationDistance: BusStationDistance?
            var distance: CLLocationDistance = 0.0

            let location = CLLocation(latitude: Double(busStop.lat), longitude: Double(busStop.lng))
            distance = currentLocation.distance(from: location)

            if busStationDistance == nil || distance < busStationDistance!.distance {
                busStationDistance = BusStationDistance(busStationItem: BBusStop(fromRealm: busStop), distance: distance)
            }

            if busStationDistance != nil {
                nearbyBusStations.append(busStationDistance!)
            }
        }

        nearbyBusStations = nearbyBusStations.sorted(by: { $0.distance < $1.distance })

        tableView.reloadData()
        locationManager?.stopUpdatingLocation()
    }
}

extension BusStopGpsViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyBusStops.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let busStationDistance = nearbyBusStops[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusStopGpsTableViewCell", for: indexPath) as! BusStopGpsTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.stationLabel.text = busStationDistance.busStation.name()
        cell.distanceLabel.text = Int(round(busStationDistance.distance)).description + "m"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busStationDistance = nearbyBusStops[indexPath.row]

        let busStopViewController = navigationController?.viewControllers[(navigationController?
                .viewControllers.index(of: self))! - 1] as! BusStopViewController

        busStopViewController.setBusStop(busStationDistance.busStation)
        self.navigationController?.popViewController(animated: true)
    }
}
