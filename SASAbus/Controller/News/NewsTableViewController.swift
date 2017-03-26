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

class NewsTableViewController: MasterTableViewController {

    var location: String!
    var newsItems: [NewsItem] = []


    init(nibName nibNameOrNil: String?, title: String?, location: String) {
        self.location = location
        super.init(nibName: nibNameOrNil, title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        self.initRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        Analytics.track("CityNews")
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsItem = self.newsItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as! NewsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.linesLabel.text = newsItem.getLinesString()
        cell.titleLabel.text = newsItem.title
        return cell;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsDetailViewController = NewsDetailViewController(nibName: "NewsDetailViewController", bundle: nil, newsItem: self.newsItems[indexPath.row]);
        self.navigationController!.pushViewController(newsDetailViewController, animated: true)

    }


    func refreshView(_ newsItems: [NewsItem]) {
        var newsItems = newsItems

        for index in stride(from: (newsItems.count - 1), through: 0, by: -1) {
            let newsItem = newsItems[index]

            // TODO

            /*if ((self.location == "BZ" && newsItem.zone != 2) || (self.location == "ME" && newsItem.zone != 1)) {
                newsItems.remove(at: index)
            }*/
        }

        self.newsItems = newsItems
        self.tableView.reloadData()
        self.tableView.separatorColor = Theme.colorGrey
        self.refreshControl!.endRefreshing()
    }

    func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.colorLightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""), attributes: [NSForegroundColorAttributeName: Theme.colorDarkGrey])
        refreshControl.addTarget(self.tabBarController, action: "getNews", for: UIControlEvents.valueChanged)
        self.refreshControl = refreshControl
    }
}
