import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import StatefulViewController

class EcoPointsSettingsViewController: UITableViewController {

    fileprivate let items: [Item] = [
        Item("Change password"),
        Item("Change profile picture"),
        Item("Log out"),
        Item("Log out from all devices"),
        Item("Delete my account", isWarning: true)
    ]

    var operationRunning: Bool = false

    var profile: Profile
    var parentVC: EcoPointsProfileViewController


    init(parent: EcoPointsProfileViewController, profile: Profile) {
        self.profile = profile
        self.parentVC = parent

        super.init(nibName: "EcoPointsSettingsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "EcoPointsProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "eco_points_profile_settings")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }


    fileprivate func logout(item: Item) {
        Log.info("Logging out user from current device")

        if !NetUtils.isOnline() {
            internetError(item: item)
            return
        }

        AnswersHelper.logProfileAction(action: "logout")

        _ = UserApi.logout(fcmToken: "")
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { _ in
                    AuthHelper.logout()
                    self.navigationController?.popViewController(animated: true)

                    self.operationRunning = false
                }, onError: { error in
                    Log.error("Could not log out: \(error)")

                    AuthHelper.checkIfUnauthorized(error)

                    self.showCloseDialog(title: "Couldn't log out", message: "Please retry again later.")

                    item.isLoading = false
                    self.tableView.reloadData()

                    self.operationRunning = false
                })
    }

    fileprivate func logoutAll(item: Item) {
        Log.info("Logging out user from all devices")

        if !NetUtils.isOnline() {
            internetError(item: item)
            return
        }

        AnswersHelper.logProfileAction(action: "logout_all")

        _ = UserApi.logoutAll()
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { _ in
                    AuthHelper.logout()
                    self.navigationController?.popViewController(animated: true)

                    self.operationRunning = false
                }, onError: { error in
                    Log.error("Could not log out from all devices: \(error)")

                    AuthHelper.checkIfUnauthorized(error)

                    self.showCloseDialog(title: "Couldn't log out", message: "Please retry again later.")

                    item.isLoading = false
                    self.tableView.reloadData()

                    self.operationRunning = false
                })
    }

    fileprivate func deleteAccount(item: Item) {
        Log.info("Deleting account")

        if !NetUtils.isOnline() {
            internetError(item: item)
            return
        }

        AnswersHelper.logProfileAction(action: "delete_account")

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

                        AuthHelper.checkIfUnauthorized(error)

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


    fileprivate func internetError(item: Item) {
        self.showCloseDialog(title: "No internet connection", message: "Please connect to the internet to continue")

        item.isLoading = false
        self.tableView.reloadData()

        operationRunning = false
    }

    func updateProfilePicture(url: String) {
        profile.imageUrl = url
        tableView.reloadData()

        parentVC.updateProfilePicture(url: url)
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
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: "eco_points_profile_settings") as! EcoPointsProfileSettingsCell

            let url = URL(string: self.profile.imageUrl)!
            cell.profilePicture.kf.setImage(with: url)

            cell.nameText.text = profile.username
            cell.levelText.text = profile.cls

            return cell
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

        if indexPath.section == 1 {
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.section == 2 {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.hidesWhenStopped = false
            indicator.isHidden = !item.isLoading
            indicator.startAnimating()

            cell.accessoryView = indicator
        }

        return cell
    }

    override func tableView(_ tV: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tV.beginUpdates()
            tV.reloadRows(at: [indexPath], with: .none)
            tV.endUpdates()
        }

        if operationRunning {
            Log.warning("An operation is already running, skipping click")
            return
        }

        /*if indexPath.section == 2 {
            return
        }*/

        // Change profile picture and password
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                // TODO: Add possibility to change password
                break
            case 1:
                let viewController = EcoPointsProfilePictureDefaultViewController(parent: self)
                self.navigationController!.pushViewController(viewController, animated: true)
            default:
                fatalError()
            }

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

        switch indexPath.row {
        case 0:
            item.isLoading = true
            logout(item: item)
        case 1:
            item.isLoading = true
            logoutAll(item: item)
        case 2:
            deleteAccount(item: item)
        default:
            fatalError()
        }
    }
}

fileprivate class Item {

    var title: String
    var isLoading: Bool
    var isWarning: Bool

    init(_ title: String, isLoading: Bool = false, isWarning: Bool = false) {
        self.title = title
        self.isLoading = isLoading
        self.isWarning = isWarning
    }
}
