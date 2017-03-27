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

    fileprivate var filteredBusLines: [BusLineFilter]!

    init(filteredBusLines: [BusLineFilter], nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.filteredBusLines = filteredBusLines
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Bus line filter", comment: "")

        collectionView.register(UINib(nibName: "BusstopFilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BusstopFilterCollectionViewCell")

        self.enableAllButton.action = #selector(BusstopFilterViewController.enableAllLines)
        self.enableAllButton.title = NSLocalizedString("Enable all", comment: "")
        self.enableAllButton.tintColor = Theme.orange

        self.disableAllButton.action = #selector(BusstopFilterViewController.disableAllLines)
        self.disableAllButton.title = NSLocalizedString("Disable all", comment: "")
        self.disableAllButton.tintColor = Theme.orange
    }

    override func viewWillDisappear(_ animated: Bool) {
        let busstopViewController = self.navigationController?.viewControllers[0] as! BusStopViewController
        busstopViewController.setFilteredBusLines(self.filteredBusLines)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredBusLines.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let busLineFilter: BusLineFilter = self.filteredBusLines[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusstopFilterCollectionViewCell", for: indexPath) as! BusstopFilterCollectionViewCell

        cell.busLineLabel.textColor = Theme.darkGrey
        cell.filterSwitch.onTintColor = Theme.orange
        cell.filterSwitch.tag = indexPath.row
        cell.filterSwitch.setOn(busLineFilter.active, animated: false)
        cell.filterSwitch.addTarget(self, action: #selector(BusstopFilterViewController.setFilterActive(_:)), for: UIControlEvents.valueChanged)
        cell.filterSwitch.accessibilityLabel = busLineFilter.busLine.name

        cell.busLineLabel.text = busLineFilter.busLine.name

        return cell;
    }

    func setFilterActive(_ sender: UISwitch) {
        self.filteredBusLines[sender.tag].active = !self.filteredBusLines[sender.tag].active
    }

    func enableAllLines() {
        for cell in self.collectionView.visibleCells as! [BusstopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(true, animated: true)
            self.filteredBusLines[cell.filterSwitch.tag].active = true
        }
    }

    func disableAllLines() {
        for cell in self.collectionView.visibleCells as! [BusstopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(false, animated: true)
            self.filteredBusLines[cell.filterSwitch.tag].active = false
        }
    }
}
