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

class ParkingLotViewController: MasterTableViewController {
    
    private struct ParkingItem {
        var freeSlots: Int
        var details: ParkingStationItem?
    }
    
    private var parkingIds = [Int]()
    private var parkingItems = [Int: ParkingItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ParkingTableViewCell", bundle: nil), forCellReuseIdentifier: "ParkingTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.initRefreshControl()
        self.getParkingSlotData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.parkingIds.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ParkingTableViewCell", forIndexPath: indexPath) as! ParkingTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.progressView.progressTintColor = Theme.colorOrange
        cell.iconImageView.image = cell.iconImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell.phoneLabel.editable = false
        cell.phoneLabel.dataDetectorTypes = UIDataDetectorTypes.PhoneNumber
        cell.phoneLabel.contentInset = UIEdgeInsets(top: -4, left: -8, bottom: 0, right: 0)
        if let parkingItem = self.parkingItems[self.parkingIds[indexPath.row]] {
            cell.backgroundColor = Theme.colorTransparent
            if (parkingItem.details != nil) {
                cell.titleLabel.text = "\(parkingItem.details!.getName())"
                if let details = parkingItem.details {
                    cell.messageLabel.text = "\(details.getSlots() - parkingItem.freeSlots)/\(details.getSlots())"
                    cell.progressView.setProgress((1 / Float(details.getSlots())) * Float(parkingItem.freeSlots), animated: false)
                    cell.addressLabel.text = details.getAddress()
                    cell.phoneLabel.text = details.getPhone()
                } else {
                    cell.progressView.progress = 0
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let parkingLotDetailViewController = ParkingLotDetailViewController(nibName: "ParkingLotDetailViewController", bundle: nil, parkingStationItem: self.parkingItems[self.parkingIds[indexPath.row]]!.details);
        self.navigationController!.pushViewController(parkingLotDetailViewController, animated: true)
    }
    
    func getParkingSlotData() {
        Alamofire.request(ParkingApiRouter.GetParkingIds()).responseJSON { response in
            if let JSON = response.result.value {
                self.parkingIds = JSON as! [Int]
                for id in self.parkingIds {
                    let parkingItem = ParkingItem(freeSlots:0, details: nil)
                    self.parkingItems[id] = parkingItem
                    self.setDetails(id)
                }
            } else {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func setFreeSlot(id: Int){
        Alamofire.request(ParkingApiRouter.GetNumberOfFreeSlots(id)).responseString { response in
            if (response.result.isSuccess) {
                self.parkingItems[id]!.freeSlots = Int((response.result.value )!)!
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            } else {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    func setDetails(id: Int) {
        Alamofire.request(ParkingApiRouter.GetParkingStation(id)).responseObject { (response: Response<ParkingStationItem, NSError>) in
            if (response.result.isSuccess) {
                self.parkingItems[id]!.details = response.result.value
                self.setFreeSlot(id)
            } else {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    private func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.colorLightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""), attributes: [NSForegroundColorAttributeName: Theme.colorDarkGrey])
        refreshControl.addTarget(self, action: "getParkingSlotData", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.track("Parkings")
    }
    
}
