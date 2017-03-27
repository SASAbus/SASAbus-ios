//
// NewsTabBarController.swift
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
import RxSwift
import RxCocoa

class NewsTabBarController: MasterTabBarController {

    var newsItems: [NewsItem] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        let newsBozenViewController = NewsTableViewController(nibName: "NewsTableViewController", title: "", location: "BZ")
        let newsMeranViewController = NewsTableViewController(nibName: "NewsTableViewController", title: "", location: "ME")

        newsBozenViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Bozen", comment: ""),
                image: UIImage(named: "wappen_bz.png"), selectedImage: nil)

        newsMeranViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Meran", comment: ""),
                image: UIImage(named: "wappen_me.png"), selectedImage: nil)

        self.viewControllers = [newsBozenViewController, newsMeranViewController]
        self.tabBar.tintColor = Theme.orange
        self.tabBar.isTranslucent = false;

        self.getNews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        Analytics.track("News")
    }


    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.getNews()
    }


    func getNews() {
        Log.info("Loading news")

        _ = NewsApi.news()
                .subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { news in
                    (self.selectedViewController as! NewsTableViewController).refreshView(news)
                }, onError: { error in
                    print(error)
                    (self.selectedViewController as! NewsTableViewController).refreshView([])
                })
    }
}
