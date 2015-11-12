//
// MenuViewController.swift
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

struct Menu {
    
    static let items:[MenuItem] = [
        MenuItem(
            title:NSLocalizedString("Busstop", comment:""),
            image:"ic_navigation_busstop",
            viewController:BusstopViewController(busStation: nil, nibName: "BusstopViewController", title: NSLocalizedString("Busstop", comment:""))),
        MenuItem(
            title:NSLocalizedString("Line", comment:""),
            image:"ic_navigation_bus",
            viewController:LineViewController(nibName: "LineViewController", title: NSLocalizedString("Line", comment:""))),
        MenuItem(
            title:NSLocalizedString("News", comment:""),
            image:"ic_navigation_news",
            viewController:NewsTabBarController(nibName: nil, title: NSLocalizedString("News", comment: ""))),
        MenuItem(
            title:NSLocalizedString("Map", comment:""),
            image:"ic_navigation_map",
            viewController:MapViewController(nibName: "MapViewController", title: NSLocalizedString("Map", comment:""))),
        MenuItem(
            title:NSLocalizedString("Parking lot", comment:""),
            image:"ic_navigation_parking",
            viewController:ParkingLotTabBarController(nibName: nil, title: NSLocalizedString("Parking lot", comment:""))),
        MenuItem(
            title:NSLocalizedString("Info", comment:""),
            image:"",
            viewController:InfoViewController(nibName: "InfoViewController", title: NSLocalizedString("Info", comment:""))),
    ];
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTableViewCell");
        tableView.backgroundColor = Theme.colorTransparent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Menu.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        
    {
        let menuItem = Menu.items[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCell", forIndexPath: indexPath) as! MenuTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = Theme.colorTransparent
        cell.titleLabel.textColor = Theme.colorWhite
        cell.titleLabel.text = menuItem.title
        if !menuItem.image.isEmpty {
            cell.iconImageView.image = UIImage(named: menuItem.image)
        }
        cell.iconImageView.image = cell.iconImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.iconImageView.tintColor = Theme.colorWhite
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let menuItem = Menu.items[indexPath.row]
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if (menuItem.viewController != nil){
            appDelegate.navigateTo(menuItem.viewController!)
        }
    }
}
