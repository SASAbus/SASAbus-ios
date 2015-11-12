//
// ParkingLotDetailViewController.swift
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
import CoreLocation

class ParkingLotDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var stations: [String] = []
    private var parkingStationItem: ParkingStationItem!
    private var nearestBusStations: [BusStationDistance] = []
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, parkingStationItem: ParkingStationItem!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.parkingStationItem = parkingStationItem
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Parking lot detail", comment: "");
        tableView.registerNib(UINib(nibName: "ParkingLotDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingLotDetailTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        self.titleLabel.text = self.parkingStationItem.getName()
        self.titleLabel.textColor = Theme.colorWhite
        self.view.backgroundColor = Theme.colorDarkGrey
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.nearestBusStations = self.getNearestBusStations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.nearestBusStations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let busStationDistance = self.nearestBusStations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("ParkingLotDetailTableViewCell", forIndexPath: indexPath) as! ParkingLotDetailTableViewCell
        cell.iconImageView.image = cell.iconImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.stationLabel.text = busStationDistance.getBusStation().getDescription()
        cell.distanceLabel.text = Int(round(busStationDistance.getDistance())).description + "m"
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let busStationDistance = self.nearestBusStations[indexPath.row]
        let busstopViewController = BusstopViewController(busStation: busStationDistance.getBusStation(), nibName: "BusstopViewController", title: NSLocalizedString("Busstop", comment:""))
        (UIApplication.sharedApplication().delegate as! AppDelegate).navigateTo(busstopViewController)
    }
    
    private func getNearestBusStations() -> [BusStationDistance] {
        let busStations: [BusStationItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]
        var nearestBusStations: [BusStationDistance] = []
        for busStation in busStations {
            var busStationDistance: BusStationDistance?
            var distance: CLLocationDistance = 0.0
            for busStop in busStation.getBusStops() {
                distance = busStop.getLocation().distanceFromLocation(self.parkingStationItem.getLocation())
                if (busStationDistance == nil || distance < busStationDistance!.getDistance()) {
                    busStationDistance = BusStationDistance(busStationItem: busStation, distance: distance)
                }
            }
            if (busStationDistance != nil) {
                nearestBusStations.append(busStationDistance!)
            }
        }
        nearestBusStations = nearestBusStations.sort({$0.getDistance() < $1.getDistance()})
        return Array(nearestBusStations[0..<5])
    }
}
