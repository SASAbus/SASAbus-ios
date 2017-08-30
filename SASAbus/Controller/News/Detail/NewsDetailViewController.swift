//
// NewsDetailViewController.swift
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

import Foundation
import UIKit

class NewsDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!

    let newsItem: News!

    init(newsItem: News) {
        self.newsItem = newsItem
        
        super.init(nibName: "NewsDetailViewController", bundle: nil)
        
        title = L10n.News.Detail.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = UIRectEdge()
        extendedLayoutIncludesOpaqueBars = false
        automaticallyAdjustsScrollViewInsets = false

        let font = UIFont.systemFont(ofSize: 17)
        titleLabel.text = newsItem.title
        
        let messageString = "<span style=\"padding: 1em; font-family:Helvetica; font-size: \(font.pointSize); color: " +
                Color.getHexColor(Theme.darkGrey) + "\">\(newsItem.message)</span>"

        webView.loadHTMLString(messageString, baseURL: nil)
        webView.isOpaque = false
        webView.backgroundColor = Theme.white
        webView.isUserInteractionEnabled = true
        webView.scrollView.isScrollEnabled = true

        view.backgroundColor = Theme.darkGrey
    }
}
