import UIKit
import SafariServices

class AboutViewController: MasterTableViewController {

    let URL_TERMS = "\(NetUtils.HOST)/terms"
    let URL_PRIVACY = "\(NetUtils.HOST)/privacy"

    let items = [
            L10n.Changelog.title,
            L10n.Feedback.title,
            L10n.Credits.title,
            L10n.About.termsOfService,
            L10n.About.privacyPolicy
    ]

    init() {
        super.init(nibName: "AboutViewController", title: L10n.About.title)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let row = tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: row, animated: true)
        }
    }
}

extension AboutViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return L10n.About.title
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "AboutTableViewCell")

        cell.textLabel?.text = items[indexPath.row]
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let controller = ChangelogViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case 1:
            let controller = ReportViewController()
            self.navigationController!.pushViewController(controller, animated: true)
        case 2:
            let controller = CreditsViewController()
            self.navigationController!.pushViewController(controller, animated: true)
            break
        case 3:
            let svc = SFSafariViewController(url: URL(string: URL_TERMS)!)
            present(svc, animated: true, completion: nil)
        case 4:
            let svc = SFSafariViewController(url: URL(string: URL_PRIVACY)!)
            present(svc, animated: true, completion: nil)
        default:
            return
        }
    }
}
