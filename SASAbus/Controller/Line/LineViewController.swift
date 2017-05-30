//
// LineViewController.swift
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
import RxCocoa
import RxSwift

class LineViewController: MasterViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: MasterTableView!

    var selectedTab: String = "FAVORITES"
    var tabId: Int = 0

    var lines: [[Line]?] = [[Line]?](repeating: nil, count: 3)


    init(title: String?) {
        super.init(nibName: "LineViewController", title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.darkGrey

        self.tabBar.tintColor = Theme.orange
        self.tabBar.isTranslucent = false
        self.tabBar.backgroundColor = Theme.white
        self.tabBar.selectedItem = self.tabBar.items![0]

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LineCell", bundle: nil), forCellReuseIdentifier: "cell_lines_all")

        var tabBarItems = tabBar.items!

        tabBarItems[0].title = NSLocalizedString("Favorites", comment: "")
        tabBarItems[1].title = NSLocalizedString("Bozen", comment: "")
        tabBarItems[2].title = NSLocalizedString("Meran", comment: "")

        parseLines()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("BusSchedules")
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return lines[tabId]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let line = self.lines[tabId]![indexPath.section]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_lines_all", for: indexPath) as! LineCell

        cell.titleLeft.text = "Line \(line.name)"
        cell.titleRight.text = line.city

        cell.subtitleTop.text = line.origin
        cell.subtitleBottom.text = line.destination

        return cell
    }


    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.tabId = item.tag

        switch self.tabId {
        case 1:
            self.selectedTab = "BZ"
        case 2:
            self.selectedTab = "ME"
        default:
            self.selectedTab = "FAVORITES"
        }

        tableView.reloadData()
    }


    func parseLines() {
        Log.info("Loading all lines")

        _ = LinesApi.getAllLines()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { lines in
                    var bz: [Line] = []
                    var me: [Line] = []

                    var isBz = true
                    var i = 0

                    let mItemsSize = lines.count

                    while i < mItemsSize {
                        let line = lines[i]

                        if line.city.lowercased().hasPrefix("me") {
                            isBz = false
                        }

                        if isBz {
                            bz.append(line)
                        } else {
                            me.append(line)
                        }

                        i += 1
                    }

                    self.lines[1] = bz
                    self.lines[2] = me

                    self.tableView.reloadData()
                }, onError: { error in
                    Log.error("Could not load all lines: \(error)")
                })
    }
}
