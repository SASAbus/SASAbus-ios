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
import RealmSwift

class ParkingDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var stations: [String] = []
    var parking: Parking!
    var nearestBusStations: [BusStopDistance] = []

    var realm = Realm.busStops()


    init(item: Parking!) {
        super.init(nibName: "ParkingDetailViewController", bundle: nil)
        self.parking = item
        
        self.title = L10n.Parking.Detail.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ParkingDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingDetailTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        self.titleLabel.text = parking.name
        self.titleLabel.textColor = Theme.white
        self.view.backgroundColor = Theme.darkGrey
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.nearestBusStations = self.getNearestBusStations()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nearestBusStations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let distance = self.nearestBusStations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingDetailTableViewCell", for: indexPath) as! ParkingDetailTableViewCell

        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.stationLabel.text = distance.busStop.name()
        cell.distanceLabel.text = Int(round(distance.distance)).description + "m"

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let distance = self.nearestBusStations[indexPath.row]
        let viewController = BusStopViewController(busStop: distance.busStop)

        (UIApplication.shared.delegate as! AppDelegate).navigateTo(viewController)
    }


    func getNearestBusStations() -> [BusStopDistance] {
        let busStops = BusStopRealmHelper.nearestBusStops(location: self.parking.location)
        return Array(busStops[0..<5])
    }
}
