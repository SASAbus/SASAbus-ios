//
// MasterTabBarController.swift
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
import DrawerController

class MasterTabBarController: UITabBarController {

    init(nibName nibNameOrNil: String?, title: String?) {
        super.init(nibName: nibNameOrNil, bundle: nil);
        self.title = title;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLeftMenuButton()
    }

    func setupLeftMenuButton() {
        let leftDrawerButton = UIBarButtonItem(image: UIImage(named: "menu_icon.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MasterTabBarController.leftDrawerButtonPress(_:)))
        leftDrawerButton.tintColor = Theme.colorWhite
        leftDrawerButton.accessibilityLabel = NSLocalizedString("Menu", comment: "")
        self.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
    }

    // MARK: - Button Handlers
    func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }
}
