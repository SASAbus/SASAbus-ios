//
// NewsTableViewController.swift
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
import StatefulViewController

class NewsTableViewController: MasterViewController, StatefulViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var newsZone: String
    var newsItems: [News] = []

    init(zone: String) {
        self.newsZone = zone
        
        super.init(nibName: "NewsTableViewController", title: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        loadingView = LoadingView(frame: view.frame)
        errorView = ErrorView(frame: view.frame, target: self.tabBarController, action: Selector("getNews"))
        emptyView = EmptyStateBaseView(frame: view.frame, nib: "EmptyStateNewsView")
        
        startLoading()

        self.initRefreshControl()
    }


    func hasContent() -> Bool {
        return !newsItems.isEmpty
    }


    func refreshView(_ newsItems: [News]) {
        self.newsItems.removeAll()
        
        for item in newsItems {
            if newsZone == item.zone {
                self.newsItems.append(item)
            }
        }

        tableView.reloadData()
        tableView.separatorColor = Theme.grey
        
        endLoading()

        tableView.refreshControl!.endRefreshing()
    }

    func initRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = Theme.lightOrange
        refreshControl.attributedTitle = NSAttributedString(string: L10n.General.pullToRefresh,
                attributes: [NSForegroundColorAttributeName: Theme.darkGrey])
        
        refreshControl.addTarget(self.tabBarController, action: Selector("getNews"), for: UIControlEvents.valueChanged)

        tableView.refreshControl = refreshControl
    }
}

extension NewsTableViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsItem = newsItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell

        cell.selectionStyle = .none
        cell.linesLabel.text = newsItem.getLinesString()
        cell.titleLabel.text = newsItem.title

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = NewsDetailViewController(newsItem: self.newsItems[indexPath.row])
        self.navigationController!.pushViewController(controller, animated: true)
    }
}
