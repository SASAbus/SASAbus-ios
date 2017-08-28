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

    static let items: [MenuItem] = [
            MenuItem(
                title: L10n.Map.title,
                    image: Asset.icNavigationMap.image,
                    viewController: MainMapViewController.getViewController()),

            MenuItem(
                    title: L10n.Departures.title,
                    image: Asset.icNavigationBusstop.image,
                    viewController: BusStopViewController()),

            MenuItem(
                    title: L10n.Line.title,
                    image: Asset.icNavigationBus.image,
                    viewController: LineViewController()),

            MenuItem(
                    title: NSLocalizedString("Route", comment: ""),
                    image: Asset.icExploreWhite.image,
                    viewController: MainRouteViewController()),

            MenuItem(
                    title: L10n.News.title,
                    image: Asset.icEventNoteWhite.image,
                    viewController: NewsTabBarController()),

            MenuItem(
                    title: L10n.Ecopoints.title,
                    image: Asset.icNaturePeopleWhite.image,
                    viewController: EcoPointsViewController()),

            MenuItem(
                    title: L10n.Parking.title,
                    image: Asset.icNavigationParking.image,
                    viewController: ParkingViewController()),

            MenuItem(
                    title: L10n.About.title,
                    image: Asset.icInfoOutlineWhite.image,
                    viewController: AboutViewController())
    ]
}

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuTableViewCell")
        tableView.backgroundColor = Theme.transparent
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menu.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = Menu.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.backgroundColor = Theme.transparent
        cell.titleLabel.textColor = Theme.white
        cell.titleLabel.text = menuItem.title

        cell.iconImageView.image = menuItem.image

        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.iconImageView.tintColor = Theme.white

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = Menu.items[indexPath.row]
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if menuItem.viewController != nil {
            appDelegate.navigateTo(menuItem.viewController!)
        }
    }
}
