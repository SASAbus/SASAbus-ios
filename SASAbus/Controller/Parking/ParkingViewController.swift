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

class ParkingViewController: MasterTableViewController {

    var items = [Parking]()

    init(title: String?) {
        super.init(nibName: "ParkingViewController", title: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ParkingTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""),
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])

        refreshControl.addTarget(self, action: #selector(parseData), for: UIControlEvents.valueChanged)

        self.refreshControl = refreshControl

        self.parseData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("Parkings")
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingTableViewCell", for: indexPath) as! ParkingTableViewCell

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.progressView.progressTintColor = Theme.orange
        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

        cell.phoneLabel.isEditable = false
        cell.phoneLabel.dataDetectorTypes = UIDataDetectorTypes.phoneNumber
        cell.phoneLabel.contentInset = UIEdgeInsets(top: -4, left: -8, bottom: 0, right: 0)

        cell.backgroundColor = Theme.transparent

        let item = items[indexPath.row]

        cell.titleLabel.text = item.name

        cell.messageLabel.text = "\(item.totalSlots - item.freeSlots)/\(item.totalSlots)"
        cell.progressView.setProgress(Float(item.freeSlots) / Float(item.totalSlots), animated: false)
        cell.addressLabel.text = item.address
        cell.phoneLabel.text = item.phone

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parkingLotDetailViewController = ParkingLotDetailViewController(nibName: "ParkingLotDetailViewController",
                bundle: nil, item: self.items[indexPath.row])

        self.navigationController!.pushViewController(parkingLotDetailViewController, animated: true)
    }


    func parseData() {
        Log.info("Loading parking data")

        _ = ParkingApi.get()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { parkings in
                    self.items.removeAll()
                    self.items.append(contentsOf: parkings)

                    self.tableView.reloadData()
                }, onError: { error in
                    Log.error(error)
                })
    }
}
