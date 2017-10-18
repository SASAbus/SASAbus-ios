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
import RealmSwift

class BusStopFavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var busStationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    fileprivate var busStop: BBusStop!
    fileprivate var favoriteBusStops: [BBusStop] = []

    let realm = try! Realm()


    init(busStop: BBusStop?) {
        super.init(nibName: "BusStopFavoritesViewController", bundle: nil)

        self.busStop = busStop
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = L10n.Departures.Favorites.title

        tableView.register(UINib(nibName: "BusStopFavoritesTableViewCell", bundle: nil), forCellReuseIdentifier: "BusStopFavoritesTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsMultipleSelectionDuringEditing = false

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
            self.busStationLabel.text = L10n.Departures.Favorites.header
        }
    }


    func loadFavoriteBusStations() {
        favoriteBusStops.removeAll()

        let favorites = realm.objects(FavoriteBusStop.self)
        let busStopRealm = Realm.busStops()

        for favorite in favorites {
            let busStop = busStopRealm.objects(BusStop.self).filter("family = \(favorite.group)").first
            if let busStop = busStop {
                favoriteBusStops.append(BBusStop(fromRealm: busStop))
            }
        }

        self.tableView.reloadData()
    }

    func saveFavoriteBusStation(_ sender: UIBarButtonItem) {
        UserRealmHelper.addFavoriteBusStop(group: self.busStop.family)

        self.loadFavoriteBusStations()
        self.busStationLabel.text = L10n.Departures.Favorites.header
        self.navigationItem.rightBarButtonItem = nil
    }
}

extension BusStopFavoritesViewController {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteBusStops.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let busStation = self.favoriteBusStops[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusStopFavoritesTableViewCell", for: indexPath) as! BusStopFavoritesTableViewCell

        cell.selectionStyle = .none
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
        if editingStyle == .delete {
            let busStop = self.favoriteBusStops[indexPath.row]

            UserRealmHelper.removeFavoriteBusStop(group: busStop.family)

            self.favoriteBusStops.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

            if busStop.name() == self.busStop.name() {
                self.busStationLabel.text = self.busStop.name()

                let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                        action: #selector(BusStopFavoritesViewController.saveFavoriteBusStation(_:)))

                addButton.tintColor = Theme.white
                self.navigationItem.rightBarButtonItem = addButton
            }
        }
    }
}
