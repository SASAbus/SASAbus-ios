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
    @IBOutlet weak var messageView: UIWebView!
    @IBOutlet weak var messageScrollView: UIScrollView!

    let newsItem: NewsItem!

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, newsItem: NewsItem) {
        self.newsItem = newsItem
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("News detail", comment: "")
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false;
        self.automaticallyAdjustsScrollViewInsets = false;
        let font = UIFont.systemFont(ofSize: 17)
        self.titleLabel.text = self.newsItem.title
        let messageString = "<span style=\"font-family:Helvetica; font-size: " + String(describing: font.pointSize) + "; color: " + ColorHelper.getHexColor(Theme.darkGrey) + "\">" + newsItem.message + "</span>"
        self.messageView.loadHTMLString(messageString, baseURL: nil)
        self.titleLabel.textColor = Theme.white
        self.messageView.isOpaque = false
        self.messageView.backgroundColor = Theme.transparent
        self.view.backgroundColor = Theme.darkGrey
        self.messageScrollView.backgroundColor = Theme.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
