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
import RxCocoa
import RxSwift
import StatefulViewController

class ParkingViewController: MasterViewController, StatefulViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var items = [Parking]()


    init() {
        super.init(nibName: "ParkingViewController", title: L10n.Parking.title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "ParkingTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        loadingView = LoadingView(frame: view.frame)
        emptyView = EmptyView(frame: view.frame)
        errorView = ErrorView(frame: view.frame, target: self, action: #selector(parseData))

        setupRefresh()
        parseData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("Parkings")
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingTableViewCell", for: indexPath) as! ParkingTableViewCell
        let item = items[indexPath.row]

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.progressView.progressTintColor = Theme.orange

        cell.phoneLabel.isEditable = false
        cell.phoneLabel.dataDetectorTypes = UIDataDetectorTypes.phoneNumber
        cell.phoneLabel.contentInset = UIEdgeInsets(top: -4, left: -8, bottom: 0, right: 0)

        cell.phoneLabel.text = item.phone
        cell.titleLabel.text = item.name
        cell.addressLabel.text = item.address

        cell.messageLabel.text = "\(item.totalSlots - item.freeSlots)/\(item.totalSlots)"
        cell.progressView.setProgress(Float(item.freeSlots) / Float(item.totalSlots), animated: false)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = ParkingDetailViewController(item: self.items[indexPath.row])
        self.navigationController!.pushViewController(detailViewController, animated: true)
    }


    func hasContent() -> Bool {
        return !items.isEmpty
    }

    func setupRefresh() {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: L10n.General.pullToRefresh,
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])

        refreshControl.addTarget(self, action: #selector(parseData), for: UIControlEvents.valueChanged)

        self.tableView.refreshControl = refreshControl
    }

    func parseData() {
        Log.info("Loading parking data")

        startLoading(animated: false)

        if !NetUtils.isOnline() {
            items.removeAll()
            tableView.reloadData()

            endLoading(animated: false, error: NetUtils.networkError())

            Log.info("Device offline")

            return
        }

        _ = ParkingApi.get()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { parkings in
                    self.items.removeAll()
                    self.items.append(contentsOf: parkings)

                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()

                    self.endLoading(animated: false)
                }, onError: { error in
                    Utils.logError(error)

                    self.items.removeAll()
                    self.tableView.reloadData()

                    self.tableView.refreshControl?.endRefreshing()
                    self.endLoading(animated: false, error: error)
                })
    }
}
