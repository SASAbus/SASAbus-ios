//
// BusstopFilterViewController.swift
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

class BusstopFilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIToolbarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var enableAllButton: UIBarButtonItem!
    @IBOutlet weak var disableAllButton: UIBarButtonItem!
    
    private var filteredBusLines: [BusLineFilter]!
    
    init(filteredBusLines: [BusLineFilter], nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.filteredBusLines = filteredBusLines
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Bus line filter", comment: "")
        collectionView.registerNib(UINib(nibName: "BusstopFilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BusstopFilterCollectionViewCell")
        self.enableAllButton.tintColor = Theme.colorOrange
        self.enableAllButton.action = "enableAllLines"
        self.enableAllButton.title = NSLocalizedString("Enable all", comment: "")
        self.disableAllButton.tintColor = Theme.colorOrange
        self.disableAllButton.action = "disableAllLines"
        self.disableAllButton.title = NSLocalizedString("Disable all", comment: "")
    }
    
    override func viewWillDisappear(animated: Bool) {
        let busstopViewController = self.navigationController?.viewControllers[0] as! BusstopViewController
        busstopViewController.setFilteredBusLines(self.filteredBusLines)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredBusLines.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let busLineFilter = self.filteredBusLines[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BusstopFilterCollectionViewCell", forIndexPath: indexPath) as! BusstopFilterCollectionViewCell
        cell.busLineLabel.textColor = Theme.colorDarkGrey
        cell.filterSwitch.onTintColor = Theme.colorOrange
        cell.filterSwitch.tag = indexPath.row
        cell.filterSwitch.setOn(busLineFilter.isActive(), animated: false)
        cell.filterSwitch.addTarget(self, action: "setFilterActive:", forControlEvents: UIControlEvents.ValueChanged)
        cell.filterSwitch.accessibilityLabel = busLineFilter.getBusLine().getShortName()
        cell.busLineLabel.text = busLineFilter.getBusLine().getShortName()
        return cell;
    }
    
    func setFilterActive(sender: UISwitch) {
        self.filteredBusLines[sender.tag].setActive(!self.filteredBusLines[sender.tag].isActive())
    }
    
    func enableAllLines() {
        for cell in self.collectionView.visibleCells() as! [BusstopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(true, animated: true)
            self.filteredBusLines[cell.filterSwitch.tag].setActive(true)
        }
    }
    
    func disableAllLines() {
        for cell in self.collectionView.visibleCells() as! [BusstopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(false, animated: true)
            self.filteredBusLines[cell.filterSwitch.tag].setActive(false)
        }
    }
}
