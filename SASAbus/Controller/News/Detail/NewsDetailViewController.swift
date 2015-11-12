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
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, newsItem: NewsItem) {
        self.newsItem = newsItem
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("News detail", comment: "")
        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars = false;
        self.automaticallyAdjustsScrollViewInsets = false;
        let font = UIFont.systemFontOfSize(17)
        self.titleLabel.text = self.newsItem.getTitle()
        let messageString = "<span style=\"font-family:Helvetica; font-size: " + String(font.pointSize) + "; color: " + ColorHelper.instance.getHexColor(Theme.colorDarkGrey) + "\">" + newsItem.getMessage() + "</span>"
        self.messageView.loadHTMLString(messageString, baseURL: nil)
        self.titleLabel.textColor = Theme.colorWhite
        self.messageView.opaque = false
        self.messageView.backgroundColor = Theme.colorTransparent
        self.view.backgroundColor = Theme.colorDarkGrey
        self.messageScrollView.backgroundColor = Theme.colorWhite
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
