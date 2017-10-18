import UIKit
import Pulley

class RouteBottomSheetViewController: UIViewController {

    @IBOutlet weak var resultsPeekView: UIView!
    @IBOutlet weak var loadingPeekView: UIView!
    
    @IBOutlet weak var chevronLeft: UIImageView!
    @IBOutlet weak var chevronRight: UIImageView!
    
    @IBOutlet weak var resultTitle: UILabel!
    @IBOutlet weak var resultSubtitle: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var parentVC: RouteResultsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        chevronLeft.tint(with: .darkGray)
        chevronRight.tint(with: .darkGray)
    }

    public func showLoadingIndicator() {
        resultsPeekView.isHidden = true
        loadingPeekView.isHidden = false

        loadingIndicator.startAnimating()
    }
}

extension RouteBottomSheetViewController: PulleyDrawerViewControllerDelegate,
        PulleyPrimaryContentControllerDelegate {

    func collapsedDrawerHeight() -> CGFloat {
        return 84
    }

    func partialRevealDrawerHeight() -> CGFloat {
        return 0
    }

    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.collapsed, .closed, .open]
    }


    func drawerPositionDidChange(drawer: PulleyViewController) {
        // scrollView.isScrollEnabled = drawer.drawerPosition == .open
    }
}
