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

    fileprivate var filteredLines: [BusLineFilter] = []


    init() {
        super.init(nibName: "BusStopFilterViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Departures.Filter.title

        collectionView.register(UINib(nibName: "BusStopFilterCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "BusStopFilterCollectionViewCell")

        enableAllButton.action = #selector(enableAllLines)
        enableAllButton.title = L10n.Departures.Filter.enableAll
        enableAllButton.tintColor = Theme.orange

        disableAllButton.action = #selector(disableAllLines)
        disableAllButton.title = L10n.Departures.Filter.disableAll
        disableAllButton.tintColor = Theme.orange

        loadAllLines()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let lines = filteredLines.filter {
            !$0.active
        }.map {
            $0.line
        }
        
        UserRealmHelper.setDisabledDepartures(lines: lines)

        let viewController = navigationController?.viewControllers[0] as! BusStopViewController
        viewController.updateFilter()
    }


    func loadAllLines() {
        let lines = Lines.ORDER
        let disabledLines = UserRealmHelper.getDisabledDepartures()

        for line in lines {
            let filter = BusLineFilter(line: line)
            filter.active = !disabledLines.contains(line)
            
            filteredLines.append(filter)
        }

        self.collectionView.reloadData()
    }


    func setFilterActive(_ sender: UISwitch) {
        filteredLines[sender.tag].active = !filteredLines[sender.tag].active
    }

    func enableAllLines() {
        for filter in filteredLines {
            filter.active = true
        }

        for cell in collectionView.visibleCells as! [BusStopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(true, animated: true)
        }
    }

    func disableAllLines() {
        for filter in filteredLines {
            filter.active = false
        }

        for cell in collectionView.visibleCells as! [BusStopFilterCollectionViewCell] {
            cell.filterSwitch.setOn(false, animated: true)
        }
    }
}

extension BusStopFilterViewController {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredLines.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let busLineFilter: BusLineFilter = self.filteredLines[indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusStopFilterCollectionViewCell",
                for: indexPath) as! BusStopFilterCollectionViewCell

        cell.busLineLabel.textColor = Theme.darkGrey

        cell.filterSwitch.onTintColor = Theme.orange
        cell.filterSwitch.tag = indexPath.row
        cell.filterSwitch.setOn(busLineFilter.active, animated: false)
        cell.filterSwitch.addTarget(self, action: #selector(setFilterActive(_:)), for: UIControlEvents.valueChanged)
        cell.filterSwitch.accessibilityLabel = Lines.lidToName(id: busLineFilter.line)

        cell.busLineLabel.text = Lines.lidToName(id: busLineFilter.line)

        return cell
    }
}
