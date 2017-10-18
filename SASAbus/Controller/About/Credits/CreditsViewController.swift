import UIKit

class CreditsViewController: UIViewController, UIToolbarDelegate {

    @IBOutlet weak var infoView: UITextView!
    @IBOutlet weak var infoTextView: UITextView!

    @IBOutlet weak var titleLabel: UILabel!


    init() {
        super.init(nibName: "CreditsViewController", bundle: nil)

        title = L10n.Credits.title
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.darkGrey

        let version = Bundle.main.versionName

        titleLabel.text = L10n.Credits.header(version)
        titleLabel.textColor = Theme.white

        infoTextView.text = L10n.Credits.copyright

        infoTextView.textColor = Theme.grey

        infoView.text = getAboutText()
        infoView.textColor = Theme.darkGrey
        infoView.isEditable = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.track("About")
    }


    func getAboutText() -> String {
        let thirdPartyTitle = L10n.Credits.Licenses.title
        let thirdPartyText = L10n.Credits.Licenses.subtitle

        return thirdPartyTitle + "\r\n\r\n" + thirdPartyText
    }
}
