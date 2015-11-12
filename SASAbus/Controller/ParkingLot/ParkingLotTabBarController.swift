//
// ParkingLotTabBarController.swift
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

class ParkingLotTabBarController: MasterTabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let parkingLotBozenViewController = ParkingLotViewController(nibName: "ParkingLotViewController", title: "")
        parkingLotBozenViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Bozen", comment: ""), image: UIImage(named: "wappen_bz.png"), selectedImage: nil)
        let parkingLotMeranViewController = UIViewController()
        parkingLotMeranViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Meran", comment: ""), image: UIImage(named: "wappen_me.png"), selectedImage: nil)
        parkingLotMeranViewController.tabBarItem.enabled = false
        self.viewControllers = [parkingLotBozenViewController, parkingLotMeranViewController]
        self.tabBar.tintColor = Theme.colorOrange
        self.tabBar.translucent = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    }
}
