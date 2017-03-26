//
// ParkingLotViewController.swift
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
import SwiftyJSON

class ParkingLotViewController: MasterTableViewController {

    class ParkingItem: JSONable {

        var freeSlots: Int
        var details: ParkingStationItem?

        required init(parameter: JSON) {
            freeSlots = parameter["free_slots"].intValue
            details = ParkingStationItem(parameter: parameter["parking"])
        }

        init(freeSlots: Int, details: ParkingStationItem?) {
            self.freeSlots = freeSlots
            self.details = details
        }
    }


    var parkingIds = [Int]()
    var parkingItems = [Int: ParkingItem]()


    init(title: String?) {
        super.init(nibName: "ParkingLotViewController", title: nil);
        self.title = title;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ParkingTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        self.initRefreshControl()
        self.getParkingSlotData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        Analytics.track("Parkings")
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.parkingIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkingTableViewCell", for: indexPath) as! ParkingTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.progressView.progressTintColor = Theme.colorOrange
        cell.iconImageView.image = cell.iconImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.phoneLabel.isEditable = false
        cell.phoneLabel.dataDetectorTypes = UIDataDetectorTypes.phoneNumber
        cell.phoneLabel.contentInset = UIEdgeInsets(top: -4, left: -8, bottom: 0, right: 0)

        if let parkingItem = self.parkingItems[self.parkingIds[indexPath.row]] {
            cell.backgroundColor = Theme.colorTransparent

            if (parkingItem.details != nil) {
                cell.titleLabel.text = "\(parkingItem.details!.name)"

                if let details = parkingItem.details {
                    cell.messageLabel.text = "\(details.slots - parkingItem.freeSlots)/\(details.slots)"
                    cell.progressView.setProgress((1 / Float(details.slots)) * Float(parkingItem.freeSlots), animated: false)
                    cell.addressLabel.text = details.address
                    cell.phoneLabel.text = details.phone
                } else {
                    cell.progressView.progress = 0
                }
            }
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parkingLotDetailViewController = ParkingLotDetailViewController(nibName: "ParkingLotDetailViewController", bundle: nil, parkingStationItem: self.parkingItems[self.parkingIds[indexPath.row]]!.details);
        self.navigationController!.pushViewController(parkingLotDetailViewController, animated: true)
    }


    func getParkingSlotData() {
        Alamofire.request(ParkingApiRouter.getParkingIds()).responseJSON { response in
            if let JSON = response.result.value {
                self.parkingIds = JSON as! [Int]
                for id in self.parkingIds {
                    let parkingItem = ParkingItem(freeSlots: 0, details: nil)
                    self.parkingItems[id] = parkingItem
                    self.setDetails(id)
                }
            } else {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func setFreeSlot(_ id: Int) {
        Alamofire.request(ParkingApiRouter.getNumberOfFreeSlots(id)).responseString { response in
            if (response.result.isSuccess) {
                self.parkingItems[id]!.freeSlots = Int((response.result.value)!)!
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            } else {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func setDetails(_ id: Int) {
        Alamofire.request(ParkingApiRouter.getParkingStation(id)).responseJSON { response in
            if (response.result.isSuccess) {
                self.parkingItems[id]!.details = ParkingStationItem(parameter: JSON(response.data))
                self.setFreeSlot(id)
            } else {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.colorLightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""), attributes: [NSForegroundColorAttributeName: Theme.colorDarkGrey])
        refreshControl.addTarget(self, action: #selector(ParkingLotViewController.getParkingSlotData), for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
}
