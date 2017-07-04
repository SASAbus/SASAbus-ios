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
import StatefulViewController
import Realm
import RealmSwift

class LineViewController: MasterViewController, StatefulViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!

    var selectedTab: String = "FAVORITES"
    var tabId: Int = 0

    var lines: [[Line]?] = [[Line]?](repeating: [], count: 3)
    var favorites: [Int] = []


    init() {
        super.init(nibName: "LineViewController", title: "Lines")
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

        loadingView = LoadingView(frame: view.frame)
        errorView = ErrorView(frame: view.frame, target: self, action: #selector(parseData))

        setupRefresh()
        parseData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("BusSchedules")

        if let row = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: row, animated: true)
        }
    }


    func parseData() {
        startLoading(animated: false)

        Log.info("Loading all lines")

        if !NetUtils.isOnline() {
            Log.error("Device offline")

            self.lines[1]?.removeAll()
            self.lines[2]?.removeAll()

            self.tableView.reloadData()

            endLoading(animated: false, error: NetUtils.networkError())
            tableView.refreshControl?.endRefreshing()

            return
        }

        _ = LinesApi.getAllLines()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { lines in
                    self.parseFavorites()

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

                    self.lines[0]?.removeAll()

                    for line in lines {
                        for favorite in self.favorites {
                            if line.id == favorite {
                                self.lines[0]?.append(line)
                            }
                        }
                    }

                    self.lines[1]?.removeAll()
                    self.lines[2]?.removeAll()

                    self.lines[1]?.append(contentsOf: bz)
                    self.lines[2]?.append(contentsOf: me)

                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()

                    self.endLoading(animated: false)
                }, onError: { error in
                    Log.error("Could not load all lines: \(error)")

                    self.lines[1]?.removeAll()
                    self.lines[2]?.removeAll()

                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()

                    self.endLoading(animated: false, error: error)
                })
    }

    func parseFavorites() {
        favorites.removeAll()

        let realm = try! Realm()
        let result = realm.objects(FavoriteLine.self)

        for item in result {
            favorites.append(item.id)
        }
    }


    func setupRefresh() {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])

        refreshControl.addTarget(self, action: #selector(parseData), for: UIControlEvents.valueChanged)

        self.tableView.refreshControl = refreshControl
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabId = item.tag

        switch self.tabId {
        case 1:
            selectedTab = "BZ"
        case 2:
            selectedTab = "ME"
        default:
            selectedTab = "FAVORITES"
        }

        tableView.reloadData()
    }

    func hasContent() -> Bool {
        return !(lines[tabId]?.isEmpty ?? true)
    }
}

extension LineViewController {

    func numberOfSections(in tableView: UITableView) -> Int {
        let count = lines[tabId]?.count ?? 0
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let line = self.lines[tabId]![indexPath.section]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_lines_all", for: indexPath) as! LineCell

        cell.titleLeft.text = Lines.line(id: line.id)
        cell.titleRight.text = line.city

        cell.subtitleTop.text = line.origin
        cell.subtitleBottom.text = line.destination

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let line = self.lines[tabId]![indexPath.section]

        let lineDetails = LineDetailsViewController(lineId: line.id, vehicle: 0)
        self.navigationController!.pushViewController(lineDetails, animated: true)
    }
}
