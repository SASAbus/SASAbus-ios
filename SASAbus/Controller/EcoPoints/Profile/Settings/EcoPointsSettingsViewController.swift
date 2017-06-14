import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import StatefulViewController

class EcoPointsSettingsViewController: UITableViewController {

    let items: [Item] = [
            Item("Change password"),
            Item("Change profile picture"),
            Item("Log out"),
            Item("Log out from all devices"),
            Item("Delete my account", isWarning: true)
    ]

    var operationRunning: Bool = false


    init() {
        super.init(nibName: "EcoPointsSettingsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "EcoPointsProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "eco_points_profile_settings")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0
    }


    func logout(item: Item) {
        if !NetUtils.isOnline() {
            internetError(item: item)
            return
        }

        // TODO
        // AnswersHelper.logProfileAction("logout")

        _ = UserApi.logout(fcmToken: "")
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { _ in
                    AuthHelper.logout()
                    self.navigationController?.popViewController(animated: true)

                    self.operationRunning = false
                }, onError: { error in
                    Log.error("Could not log out: \(error)")

                    self.showCloseDialog(title: "Couldn't log out", message: "Please retry again later.")

                    item.isLoading = false
                    self.tableView.reloadData()

                    self.operationRunning = false
                })
    }

    func logoutAll(item: Item) {
        if !NetUtils.isOnline() {
            internetError(item: item)
            return
        }

        // TODO
        // AnswersHelper.logProfileAction("logout_all")

        _ = UserApi.logoutAll()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { _ in
                    AuthHelper.logout()
                    self.navigationController?.popViewController(animated: true)

                    self.operationRunning = false
                }, onError: { error in
                    Log.error("Could not log out from all devices: \(error)")

                    self.showCloseDialog(title: "Couldn't log out", message: "Please retry again later.")

                    item.isLoading = false
                    self.tableView.reloadData()

                    self.operationRunning = false
                })
    }

    func deleteAccount(item: Item) {
        if !NetUtils.isOnline() {
            internetError(item: item)
            return
        }

        // TODO
        // AnswersHelper.logProfileAction("delete_account")

        let alert = UIAlertController(
                title: "Delete account?",
                message: "Are you sure? This cannot be undone.",
                preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            item.isLoading = true
            self.tableView.reloadData()

            _ = UserApi.delete()
                    .subscribeOn(MainScheduler.background)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { _ in
                        AuthHelper.logout()
                        self.navigationController?.popViewController(animated: true)

                        self.operationRunning = false
                    }, onError: { error in
                        Log.error("Could not delete account: \(error)")
                        self.showCloseDialog(title: "Couldn't delete account", message: "Please retry again later.")

                        item.isLoading = false
                        self.tableView.reloadData()

                        self.operationRunning = false
                    })
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.operationRunning = false
        }))

        self.present(alert, animated: true, completion: nil)
    }


    func internetError(item: Item) {
        self.showCloseDialog(title: "No internet connection", message: "Please connect to the internet to continue")

        item.isLoading = false
        self.tableView.reloadData()

        operationRunning = false
    }
}

extension EcoPointsSettingsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }


    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile"
        } else if section == 1 {
            return "Settings"
        } else {
            return "Account"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else {
            return 3
        }
    }

    override func tableView(_ tV: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "eco_points_profile_settings")!
        }

        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") ??
                UITableViewCell(style: .default, reuseIdentifier: "cell")

        var sumSections = 0
        for i in 1..<indexPath.section {
            let rowsInSection = tV.numberOfRows(inSection: i)
            sumSections += rowsInSection
        }

        let index = sumSections + indexPath.row
        let item: Item = items[index]

        cell.textLabel?.text = item.title

        if item.isWarning {
            cell.textLabel?.textColor = .red
        } else {
            cell.textLabel?.textColor = .black
        }

        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.hidesWhenStopped = false
        indicator.isHidden = !item.isLoading
        indicator.startAnimating()

        cell.accessoryView = indicator

        return cell
    }

    override func tableView(_ tV: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tV.reloadRows(at: [indexPath], with: .automatic)
        }

        if operationRunning {
            return
        }

        if indexPath.section != 2 {
            return
        }

        operationRunning = true

        var sumSections = 0
        for i in 1..<indexPath.section {
            let rowsInSection = tV.numberOfRows(inSection: i)
            sumSections += rowsInSection
        }

        let index = sumSections + indexPath.row
        let item: Item = items[index]
        item.isLoading = true

        switch indexPath.row {
        case 0:
            logout(item: item)
        case 1:
            logoutAll(item: item)
        case 2:
            item.isLoading = false
            deleteAccount(item: item)
        default:
            fatalError()
        }
    }
}

extension EcoPointsSettingsViewController {

    class Item {

        var title: String
        var isLoading: Bool
        var isWarning: Bool

        init(_ title: String, isLoading: Bool = false, isWarning: Bool = false) {
            self.title = title
            self.isLoading = isLoading
            self.isWarning = isWarning
        }
    }

}
