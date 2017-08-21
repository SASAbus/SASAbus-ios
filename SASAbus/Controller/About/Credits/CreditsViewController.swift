import UIKit

class CreditsViewController: UIViewController, UIToolbarDelegate {

    @IBOutlet weak var infoView: UITextView!
    @IBOutlet weak var infoTextView: UITextView!

    @IBOutlet weak var helpView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!


    init() {
        super.init(nibName: "CreditsViewController", bundle: nil)

        title = "Credits"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.darkGrey

        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as! String

        titleLabel.text = NSLocalizedString("SASAbus by Raiffeisen OnLine - \(version)", comment: "")
        titleLabel.textColor = Theme.white

        infoTextView.text = NSLocalizedString("© 2015 - 2016 Markus Windegger, Raiffeisen OnLine Gmbh (Norman Marmsoler, " +
                "Jürgen Sprenger, Aaron Falk)", comment: "")

        infoTextView.textColor = Theme.grey

        infoView.text = getAboutText()
        infoView.textColor = Theme.darkGrey
        infoView.isEditable = false

        helpView.text = NSLocalizedString("For suggestions or help please mail to ios@sasabz.it", comment: "")
        helpView.textColor = Theme.darkGrey
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("About")
    }


    func getAboutText() -> String {
        let thirdPartyTitle = NSLocalizedString("The following sets forth attribution notices for third party software " +
                "that may be contained in portions of the product. We thank the open source community for all their contributions.", comment: "")

        let thirdPartyText = NSLocalizedString("• DrawerController (MIT)\r\n• AlamoFire (MIT)\r\n• zipzap (BSD)\r\n" +
                "• KDCircularProgress (MIT)\r\n• SwiftValidator (MIT)", comment: "")

        return thirdPartyTitle + "\r\n\r\n" + thirdPartyText
    }
}
