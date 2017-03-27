//
// BusstopGpsViewController.swift
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

class BusstopGpsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var busStationLabel: UILabel!
    @IBOutlet weak var tableView: MasterTableView!

    fileprivate var busStation: BusStationItem!
    fileprivate var nearbyBusStations: [BusStationDistance]! = []
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "BusstopGpsTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopGpsTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.locationManager = CLLocationManager()
        self.title = NSLocalizedString("Bus stops near you", comment: "")
        self.view.backgroundColor = Theme.colorDarkGrey
        self.busStationLabel.textColor = Theme.colorWhite
        if (self.busStation != nil) {
            self.busStationLabel.text = self.busStation.getDescription()
        } else {
            self.busStationLabel.text = NSLocalizedString("Select a nearby bus station", comment: "")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.locationManager!.stopUpdatingLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.locationManager!.requestAlwaysAuthorization()
        self.locationManager!.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager!.startUpdatingLocation()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nearbyBusStations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let busStationDistance = self.nearbyBusStations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusstopGpsTableViewCell", for: indexPath) as! BusstopGpsTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.stationLabel.text = busStationDistance.busStation.getDescription()
        cell.distanceLabel.text = Int(round(busStationDistance.distance)).description + "m"

        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busStationDistance = self.nearbyBusStations[indexPath.row]
        let busstopViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.index(of: self))! - 1] as! BusStopViewController

        busstopViewController.setBusStation(busStationDistance.busStation)
        self.navigationController?.popViewController(animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let location = locationArray.lastObject as? CLLocation

        if location != nil {
            let busStations = (SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_ORT) as [BusStationItem]).filter({ $0.busStops.filter({ $0.location.distance(from: location!) < Config.busStopDistanceThreshold }).count > 0 })
            var nearbyBusStations: [BusStationDistance] = []

            for busStation in busStations {
                var busStationDistance: BusStationDistance?
                var distance: CLLocationDistance = 0.0
                for busStop in busStation.busStops {
                    distance = busStop.location.distance(from: location!)
                    if (busStationDistance == nil || distance < busStationDistance!.distance) {
                        busStationDistance = BusStationDistance(busStationItem: busStation, distance: distance)
                    }
                }
                if (busStationDistance != nil) {
                    nearbyBusStations.append(busStationDistance!)
                }
            }

            self.nearbyBusStations = nearbyBusStations.sorted(by: { $0.distance < $1.distance })
            self.tableView.reloadData()
            self.locationManager?.stopUpdatingLocation()
        }
    }
}
