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
        tableView.registerNib(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsTableViewCell");
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.initRefreshControl()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return newsItems.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
        
    {
        let newsItem = self.newsItems[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsTableViewCell", forIndexPath: indexPath) as! NewsTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.linesLabel.text = newsItem.getLinesString()
        cell.titleLabel.text = newsItem.getTitle()
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let newsDetailViewController = NewsDetailViewController(nibName: "NewsDetailViewController", bundle: nil, newsItem: self.newsItems[indexPath.row]);
        self.navigationController!.pushViewController(newsDetailViewController, animated: true)
        
    }
    
    private func initRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Theme.colorLightOrange
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("pull to refresh", comment: ""), attributes: [NSForegroundColorAttributeName: Theme.colorDarkGrey])
        refreshControl.addTarget(self.tabBarController, action: "getNews", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
    }
    
    func refreshView(var newsItems: [NewsItem]) {
        for index in (newsItems.count - 1).stride(through: 0, by: -1) {
            let newsItem = newsItems[index]
            if (newsItem.getArea() != 0 && ((self.location == "BZ" && newsItem.getArea() != 2) || (self.location == "ME" && newsItem.getArea() != 1))) {
                newsItems.removeAtIndex(index)
            }
        }
        self.newsItems = newsItems
        self.tableView.reloadData()
        self.tableView.separatorColor = Theme.colorGrey
        self.refreshControl!.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.track("CityNews")
    }
}
