//
// BusstopFavoritesViewController.swift
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

class BusStopFavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var busStationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    fileprivate var busStop: BBusStop!
    fileprivate var favoriteBusStops: [BBusStop]!

    init(busStop: BBusStop?) {
        super.init(nibName: "BusStopFavoritesViewController", bundle: nil)

        self.busStop = busStop
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Bus station favorites", comment: "")

        tableView.register(UINib(nibName: "BusStopFavoritesTableViewCell", bundle: nil), forCellReuseIdentifier: "BusStopFavoritesTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsMultipleSelectionDuringEditing = false;

        self.title = NSLocalizedString("Bus stop favorites", comment: "")
        self.view.backgroundColor = Theme.darkGrey
        self.busStationLabel.textColor = Theme.white
        self.loadFavoriteBusStations()

        if (self.busStop != nil && self.favoriteBusStops.find({ $0.name() == self.busStop!.name() }) == nil) {
            self.busStationLabel.text = self.busStop.name()

            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self,
                    action: #selector(BusStopFavoritesViewController.saveFavoriteBusStation(_:)))

            addButton.tintColor = Theme.white
            self.navigationItem.rightBarButtonItem = addButton
        } else {
            self.busStationLabel.text = NSLocalizedString("Select a bus station from your favorites", comment: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteBusStops.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let busStation = self.favoriteBusStops[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusStopFavoritesTableViewCell", for: indexPath) as! BusStopFavoritesTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.busStationLabel.text = busStation.name()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busStop = self.favoriteBusStops[indexPath.row]

        let busStopViewController = self.navigationController?.viewControllers[(self.navigationController?
                .viewControllers.index(of: self))! - 1] as! BusStopViewController

        busStopViewController.setBusStop(busStop)
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let busStop = self.favoriteBusStops[indexPath.row]

            if UserDefaultHelper.instance.removeFavoriteBusStation(busStop) {
                self.favoriteBusStops.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

                if busStop.name() == self.busStop.name() {
                    self.busStationLabel.text = self.busStop.name()

                    let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self,
                            action: #selector(BusStopFavoritesViewController.saveFavoriteBusStation(_:)))

                    addButton.tintColor = Theme.white
                    self.navigationItem.rightBarButtonItem = addButton
                }
            }
        }
    }

    fileprivate func loadFavoriteBusStations() {
        self.favoriteBusStops = UserDefaultHelper.instance.getFavoriteBusStops()
        self.tableView.reloadData()
    }

    func saveFavoriteBusStation(_ sender: UIBarButtonItem) {
        if UserDefaultHelper.instance.addFavoriteBusStation(self.busStop) {
            self.loadFavoriteBusStations()
            self.busStationLabel.text = NSLocalizedString("Select a bus station from your favorites", comment: "")
            self.navigationItem.rightBarButtonItem = nil
        }
    }
}
