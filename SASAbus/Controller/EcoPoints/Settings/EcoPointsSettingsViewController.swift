import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import StatefulViewController

class EcoPointsSettingsViewController: UIViewController, UITableViewDataSource,
        UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!


    init() {
        super.init(nibName: "EcoPointsSettingsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "EcoPointsProfileSettingsCell", bundle: nil), forCellReuseIdentifier: "eco_points_profile_settings")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Profile"
        } else if section == 1 {
            return "Settings"
        } else {
            return "Account"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else {
            return 3
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "eco_points_profile_settings")!
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: "test")
        }
    }
}
