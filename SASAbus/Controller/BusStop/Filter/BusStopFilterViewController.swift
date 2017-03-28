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

class BusStopFilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIToolbarDelegate {

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

        title = NSLocalizedString("Bus line filter", comment: "")

        collectionView.register(UINib(nibName: "BusStopFilterCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "BusStopFilterCollectionViewCell")

        enableAllButton.action = #selector(enableAllLines)
        enableAllButton.title = NSLocalizedString("Enable all", comment: "")
        enableAllButton.tintColor = Theme.orange

        disableAllButton.action = #selector(disableAllLines)
        disableAllButton.title = NSLocalizedString("Disable all", comment: "")
        disableAllButton.tintColor = Theme.orange
    }

    override func viewWillDisappear(_ animated: Bool) {
        let busStopViewController = navigationController?.viewControllers[0] as! BusStopViewController
        busStopViewController.setFilteredBusLines(filteredBusLines)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredBusLines.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let busLineFilter: BusLineFilter = self.filteredBusLines[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusStopFilterCollectionViewCell",
                for: indexPath) as! BusStopFilterCollectionViewCell

        cell.busLineLabel.textColor = Theme.darkGrey
        cell.filterSwitch.onTintColor = Theme.orange
        cell.filterSwitch.tag = indexPath.row
        cell.filterSwitch.setOn(busLineFilter.active, animated: false)
        cell.filterSwitch.addTarget(self, action: #selector(setFilterActive(_:)), for: UIControlEvents.valueChanged)
        cell.filterSwitch.accessibilityLabel = busLineFilter.busLine.name

        cell.busLineLabel.text = busLineFilter.busLine.name

        return cell
    }


    func setFilterActive(_ sender: UISwitch) {
        filteredBusLines[sender.tag].active = !filteredBusLines[sender.tag].active
    }

    func enableAllLines() {
        for cell in collectionView.visibleCells as! [BusStopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(true, animated: true)
            filteredBusLines[cell.filterSwitch.tag].active = true
        }
    }

    func disableAllLines() {
        for cell in collectionView.visibleCells as! [BusStopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(false, animated: true)
            filteredBusLines[cell.filterSwitch.tag].active = false
        }
    }
}