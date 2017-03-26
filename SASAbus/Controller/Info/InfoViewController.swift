//
// InfoViewController.swift
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

class InfoViewController: MasterViewController, UIToolbarDelegate {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var aboutButton: UIBarButtonItem!
    @IBOutlet weak var privacyButton: UIBarButtonItem!
    @IBOutlet weak var infoView: UITextView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var helpView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!

    init(title: String?) {
        super.init(nibName: "InfoViewController", title: title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.colorDarkGrey

        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String

        self.titleLabel.text = NSLocalizedString("SASAbus by Raiffeisen OnLine - \(version)", comment: "")
        self.titleLabel.textColor = Theme.colorWhite
        self.infoTextView.text = NSLocalizedString("© 2015 - 2016 Markus Windegger, Raiffeisen OnLine Gmbh (Norman Marmsoler, Jürgen Sprenger, Aaron Falk)", comment: "")
        self.infoTextView.textColor = Theme.colorGrey
        self.infoView.text = self.getAboutText()
        self.toolBar.tintColor = Theme.colorOrange
        self.infoView.textColor = Theme.colorDarkGrey
        self.helpView.text = NSLocalizedString("For suggestions or help please mail to ios@sasabz.it", comment: "")
        self.helpView.textColor = Theme.colorDarkGrey
        self.aboutButton.target = self
        self.aboutButton.action = #selector(InfoViewController.toggleInfo(_:))
        self.privacyButton.target = self
        self.privacyButton.action = #selector(InfoViewController.toggleInfo(_:))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        self.track("About")
    }


    func toggleInfo(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            self.infoView.text = self.getAboutText()
        case 1:
            self.infoView.attributedText = self.getPrivacyText()
        default:
            break
        }
    }


    fileprivate func getAboutText() -> String {
        let thirdPartyTitle = NSLocalizedString("The following sets forth attribution notices for third party software that may be contained in portions of the product. We thank the open source community for all their contributions.", comment: "")
        let thirdPartyText = NSLocalizedString("• DrawerController (MIT)\r\n• AlamoFire (MIT)\r\n• zipzap (BSD)\r\n• KDCircularProgress (MIT)\r\n• SwiftValidator (MIT)", comment: "")
        return thirdPartyTitle + "\r\n\r\n" + thirdPartyText
    }

    fileprivate func getPrivacyText() -> NSAttributedString {
        var returnValue = NSAttributedString(string: "")

        do {
            let font = UIFont.systemFont(ofSize: 14)
            let privacyHtml: String = "<span style=\"font-family:Helvetica; font-size: " + String(describing: font.pointSize) + "; color: " + ColorHelper.getHexColor(Theme.colorDarkGrey) + "\">" + UserDefaultHelper.instance.getPrivacyHtml() + "</span>"
            let privacyData = privacyHtml.data(using: String.Encoding.utf8, allowLossyConversion: false)
            returnValue = try NSAttributedString(data: privacyData!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        } catch {
        }

        return returnValue;

    }
}
