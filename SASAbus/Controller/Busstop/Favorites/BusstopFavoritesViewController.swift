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
    
    private var busStation: BusStationItem!
    private var favoriteBusStations: [BusStationItem]!
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, busStation: BusStationItem?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.busStation = busStation
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Bus station favorites", comment: "")
        tableView.registerNib(UINib(nibName: "BusstopFavoritesTableViewCell", bundle: nil), forCellReuseIdentifier: "BusstopFavoritesTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsMultipleSelectionDuringEditing = false;
        self.title = NSLocalizedString("Bus stop favorites", comment: "")
        self.view.backgroundColor = Theme.colorDarkGrey
        self.busStationLabel.textColor = Theme.colorWhite
        self.loadFavoriteBusStations()
        if (self.busStation != nil && self.favoriteBusStations.find({$0.getName() == self.busStation!.getName()}) == nil) {
            self.busStationLabel.text = self.busStation.getDescription()
            let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "saveFavoriteBusStation:")
            addButton.tintColor = Theme.colorWhite
            self.navigationItem.rightBarButtonItem = addButton
        } else {
            self.busStationLabel.text = NSLocalizedString("Select a bus station from your favorites", comment: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.favoriteBusStations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let busStation = self.favoriteBusStations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("BusstopFavoritesTableViewCell", forIndexPath: indexPath) as! BusstopFavoritesTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.busStationLabel.text = busStation.getDescription()
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let busStation = self.favoriteBusStations[indexPath.row]
        let busstopViewController = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.indexOf(self))! - 1] as! BusstopViewController
        busstopViewController.setBusStation(busStation)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let busStation = self.favoriteBusStations[indexPath.row]
            if UserDefaultHelper.instance.removeFavoriteBusStation(busStation) {
                self.favoriteBusStations.removeAtIndex(indexPath.row)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                if busStation.getName() == self.busStation.getName() {
                    self.busStationLabel.text = self.busStation.getDescription()
                    let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "saveFavoriteBusStation:")
                    addButton.tintColor = Theme.colorWhite
                    self.navigationItem.rightBarButtonItem = addButton
                }
            }
        }
    }
    
    private func loadFavoriteBusStations() {
        self.favoriteBusStations = UserDefaultHelper.instance.getFavoriteBusStations()
        self.tableView.reloadData()
    }
    
    func saveFavoriteBusStation(sender: UIBarButtonItem) {
        if UserDefaultHelper.instance.addFavoriteBusStation(self.busStation) {
            self.loadFavoriteBusStations()
            self.busStationLabel.text = NSLocalizedString("Select a bus station from your favorites", comment: "")
            self.navigationItem.rightBarButtonItem = nil
        }
    }
}
