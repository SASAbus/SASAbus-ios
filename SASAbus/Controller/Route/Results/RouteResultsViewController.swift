import UIKit

class RouteResultsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var originLabel: UIButton!

    var parentVC: MainRouteViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "RouteResultsLoadingCell", bundle: nil),
                forCellReuseIdentifier: "RouteResultsLoadingCell")
    }

    @IBAction func changeOrigin(_ sender: Any) {
        Log.error("Origin button click")

        parentVC.setDrawerPosition(position: .open, animated: true, completion: { _ in
            self.parentVC.routeController.highlightOriginText()
        }, index: parentVC.routeController.drawerIndex())
    }

    @IBAction func hideRoute(_ sender: Any) {
        Log.error("Hide button click")

        parentVC.setDrawerPosition(position: .closed, animated: true, index: drawerIndex())
        parentVC.setDrawerPosition(position: .collapsed, animated: true, index: parentVC.searchController.drawerIndex())
    }
}


extension RouteResultsViewController: PulleyDrawerViewControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 206
    }

    func drawerIndex() -> Int {
        return 1
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

extension RouteResultsViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteResultsLoadingCell", for: indexPath)
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO Change this click action to the button once bug is fixed

        changeOrigin(self)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
