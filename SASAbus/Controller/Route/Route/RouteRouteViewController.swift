import UIKit

class RouteRouteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBackground: UIView!

    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!

    var parentVC: MainRouteViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBackground.layer.cornerRadius = 4
    }

    func highlightOriginText() {
        originTextField.becomeFirstResponder()
        originTextField.selectedTextRange = originTextField.textRange(from: originTextField.beginningOfDocument,
                to: originTextField.endOfDocument)
    }

    @IBAction func findNewRoute(_ sender: Any) {
        parentVC.setDrawerPosition(position: .closed, animated: true, index: drawerIndex())
    }

    @IBAction func cancelNewRoute(_ sender: Any) {
        parentVC.setDrawerPosition(position: .closed, animated: true, index: drawerIndex())
    }
}


extension RouteRouteViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 164
    }

    func drawerIndex() -> Int {
        return 2
    }

    func initialPosition() -> PulleyPosition {
        return PulleyPosition.closed
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

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        findNewRoute(self)

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
