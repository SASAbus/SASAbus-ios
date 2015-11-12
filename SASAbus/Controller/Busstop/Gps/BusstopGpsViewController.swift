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
    
    private var busStation: BusStationItem!
    private var nearbyBusStations: [BusStationDistance]! = []
    var locationManager:CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "BusstopGpsTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopGpsTableViewCell");
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager!.stopUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locationManager!.requestAlwaysAuthorization()
        self.locationManager!.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager!.startUpdatingLocation()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.nearbyBusStations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let busStationDistance = self.nearbyBusStations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("BusstopGpsTableViewCell", forIndexPath: indexPath) as! BusstopGpsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.iconImageView.image = cell.iconImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.stationLabel.text = busStationDistance.getBusStation().getDescription()
        cell.distanceLabel.text = Int(round(busStationDistance.getDistance())).description + "m"
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let busStationDistance = self.nearbyBusStations[indexPath.row]
        let busstopViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.indexOf(self))! - 1] as! BusstopViewController
        busstopViewController.setBusStation(busStationDistance.getBusStation())
        self.navigationController?.popViewControllerAnimated(true)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let location = locationArray.lastObject as? CLLocation
        if location != nil {
            let busStations = (SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]).filter({$0.getBusStops().filter({$0.getLocation().distanceFromLocation(location!) < Configuration.busStopDistanceTreshold}).count > 0})
            var nearbyBusStations: [BusStationDistance] = []
            for busStation in busStations {
                var busStationDistance: BusStationDistance?
                var distance: CLLocationDistance = 0.0
                for busStop in busStation.getBusStops() {
                    distance = busStop.getLocation().distanceFromLocation(location!)
                    if (busStationDistance == nil || distance < busStationDistance!.getDistance()) {
                        busStationDistance = BusStationDistance(busStationItem: busStation, distance: distance)
                    }
                }
                if (busStationDistance != nil) {
                    nearbyBusStations.append(busStationDistance!)
                }
            }
            self.nearbyBusStations = nearbyBusStations.sort({$0.getDistance() < $1.getDistance()})
            self.tableView.reloadData()
            self.locationManager?.stopUpdatingLocation()
        }
    }

}
