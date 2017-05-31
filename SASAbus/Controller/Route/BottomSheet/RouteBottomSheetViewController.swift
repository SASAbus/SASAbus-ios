import UIKit
import Pulley

class RouteBottomSheetViewController: UIViewController, PulleyDrawerViewControllerDelegate,
        PulleyPrimaryContentControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBackground: UIView!

    var parentVC: MainRouteViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBackground.layer.cornerRadius = 4
    }

    func collapsedDrawerHeight() -> CGFloat {
        return 160
    }

    func partialRevealDrawerHeight() -> CGFloat {
        return 160
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [PulleyPosition.closed, PulleyPosition.collapsed, PulleyPosition.open]
    }

    func onPeekClick(gestureRecognizer: UIGestureRecognizer) {
        self.parentVC?.setDrawerPosition(position: .open, animated: true)
    }

    func drawerPositionDidChange(drawer: PulleyViewController) {
        tableView.isScrollEnabled = drawer.drawerPosition == .open

        if drawer.drawerPosition != .open {
            // searchBar.resignFirstResponder()
        }
    }
}

extension RouteBottomSheetViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        Log.error("textFieldShouldBeginEditing")

        if let drawerVC = self.parent as? PulleyViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }

        return true
    }
}
