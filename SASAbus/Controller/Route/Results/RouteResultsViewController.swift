import UIKit

class RouteResultsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var parentVC: MainRouteViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension RouteResultsViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 110
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [PulleyPosition.open, PulleyPosition.collapsed, PulleyPosition.closed]
    }

    func drawerIndex() -> Int {
        return 1
    }

    func initialPosition() -> PulleyPosition {
        return PulleyPosition.closed
    }
}

extension RouteResultsViewController: PulleyPrimaryContentControllerDelegate {

    func drawerPositionDidChange(drawer: MultiplePulleyViewController) {
        /*tableView.isScrollEnabled = drawer.drawerPosition == .open

        if drawer.drawerPosition != .open {
            // searchBar.resignFirstResponder()
        }*/
    }
}


extension RouteResultsViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        Log.error("textFieldShouldBeginEditing")

        if let drawerVC = self.parent as? MultiplePulleyViewController {
            // drawerVC.setDrawerPosition(position: .open, animated: true)
        }

        return true
    }
}

extension RouteResultsViewController: UITableViewDelegate, UITableViewDataSource {

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
