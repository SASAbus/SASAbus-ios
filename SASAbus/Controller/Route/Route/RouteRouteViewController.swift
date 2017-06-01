import UIKit

class RouteRouteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBackground: UIView!

    var parentVC: MainRouteViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBackground.layer.cornerRadius = 4
    }
}

extension RouteRouteViewController: PulleyDrawerViewControllerDelegate, PulleyPrimaryContentControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 164
    }

    func partialRevealDrawerHeight() -> CGFloat {
        return 0
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [PulleyPosition.open, PulleyPosition.collapsed, PulleyPosition.closed]
    }

    func drawerPositionDidChange(drawer: MultiplePulleyViewController) {
        /*tableView.isScrollEnabled = drawer.drawerPosition == .open

        if drawer.drawerPosition != .open {
            // searchBar.resignFirstResponder()
        }*/
    }
}

extension RouteRouteViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        Log.error("textFieldShouldBeginEditing")

        if let drawerVC = self.parent as? MultiplePulleyViewController {
            // drawerVC.setDrawerPosition(position: .open, animated: true)
        }

        return true
    }
}

extension RouteRouteViewController: UITableViewDelegate, UITableViewDataSource {

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
