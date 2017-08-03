import UIKit
import Pulley

class RouteBottomSheetViewController: UIViewController {

    var parentVC: RouteResultsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension RouteBottomSheetViewController: PulleyDrawerViewControllerDelegate,
        PulleyPrimaryContentControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 64
    }

    func partialRevealDrawerHeight() -> CGFloat {
        return 264
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .closed, .open, .partiallyRevealed]
    }


    func drawerPositionDidChange(drawer: PulleyViewController) {
        // scrollView.isScrollEnabled = drawer.drawerPosition == .open
    }
}
