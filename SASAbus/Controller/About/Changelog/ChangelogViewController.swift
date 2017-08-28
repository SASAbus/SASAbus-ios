import UIKit

class ChangelogViewController: UITableViewController, UIToolbarDelegate {

    init() {
        super.init(nibName: "ChangelogViewController", bundle: nil)

        title = "Changelog"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
