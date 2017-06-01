import UIKit

class RouteSearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var parentVC: MainRouteViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension RouteSearchViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 44
    }

    func drawerIndex() -> Int {
        return 0
    }

    func initialPosition() -> PulleyPosition {
        return PulleyPosition.collapsed
    }
}

extension RouteSearchViewController: PulleyPrimaryContentControllerDelegate {

    func drawerPositionDidChange(drawer: MultiplePulleyViewController) {
        /*tableView.isScrollEnabled = drawer.drawerPosition == .open

        if drawer.drawerPosition != .open {
            // searchBar.resignFirstResponder()
        }*/
    }
}


extension RouteSearchViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        Log.error("textFieldShouldBeginEditing")

        if let drawerVC = self.parent as? MultiplePulleyViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true, index: drawerIndex())
        }

        return true
    }
}

extension RouteSearchViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "lol")

        cell.backgroundColor = UIColor.clear
        cell.textLabel!.text = "Piazza Walther"
        cell.detailTextLabel!.text = "Bolzano"

        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
}
