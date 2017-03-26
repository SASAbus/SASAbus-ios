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

class BusstopFavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var busStationLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    fileprivate var busStation: BusStationItem!
    fileprivate var favoriteBusStations: [BusStationItem]!

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, busStation: BusStationItem?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.busStation = busStation
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Bus station favorites", comment: "")

        tableView.register(UINib(nibName: "BusstopFavoritesTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopFavoritesTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsMultipleSelectionDuringEditing = false;

        self.title = NSLocalizedString("Bus stop favorites", comment: "")
        self.view.backgroundColor = Theme.colorDarkGrey
        self.busStationLabel.textColor = Theme.colorWhite
        self.loadFavoriteBusStations()

        if (self.busStation != nil && self.favoriteBusStations.find(predicate: { $0.name == self.busStation!.name }) == nil) {
            self.busStationLabel.text = self.busStation.getDescription()
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(BusstopFavoritesViewController.saveFavoriteBusStation(_:)))
            addButton.tintColor = Theme.colorWhite
            self.navigationItem.rightBarButtonItem = addButton
        } else {
            self.busStationLabel.text = NSLocalizedString("Select a bus station from your favorites", comment: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteBusStations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let busStation = self.favoriteBusStations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusstopFavoritesTableViewCell", for: indexPath) as! BusstopFavoritesTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.busStationLabel.text = busStation.getDescription()
        return cell;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let busStation = self.favoriteBusStations[indexPath.row]
        let busstopViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.index(of: self))! - 1] as! BusStopViewController
        busstopViewController.setBusStation(busStation)
        self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let busStation = self.favoriteBusStations[indexPath.row]

            if UserDefaultHelper.instance.removeFavoriteBusStation(busStation) {
                self.favoriteBusStations.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

                if busStation.name == self.busStation.name {
                    self.busStationLabel.text = self.busStation.getDescription()
                    let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(BusstopFavoritesViewController.saveFavoriteBusStation(_:)))
                    addButton.tintColor = Theme.colorWhite
                    self.navigationItem.rightBarButtonItem = addButton
                }
            }
        }
    }

    fileprivate func loadFavoriteBusStations() {
        self.favoriteBusStations = UserDefaultHelper.instance.getFavoriteBusStations()
        self.tableView.reloadData()
    }

    func saveFavoriteBusStation(_ sender: UIBarButtonItem) {
        if UserDefaultHelper.instance.addFavoriteBusStation(self.busStation) {
            self.loadFavoriteBusStations()
            self.busStationLabel.text = NSLocalizedString("Select a bus station from your favorites", comment: "")
            self.navigationItem.rightBarButtonItem = nil
        }
    }
}
