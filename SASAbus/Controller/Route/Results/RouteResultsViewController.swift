import UIKit

class RouteResultsViewController: BottomSheetViewController {

    var parentVC: MainRouteViewController!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }


    static func getViewController() -> RouteResultsViewController {
        let contentNib = UINib(nibName: "RouteMapViewController", bundle: nil)
        let contentViewController = contentNib.instantiate(withOwner: self)[0] as! RouteMapViewController

        let drawerNib = UINib(nibName: "RouteBottomSheetViewController", bundle: nil)
        let drawerViewController = drawerNib.instantiate(withOwner: self)[0] as! RouteBottomSheetViewController

        let mainViewController = RouteResultsViewController(
                contentViewController: contentViewController,
                drawerViewController: drawerViewController
        )

        contentViewController.parentVC = mainViewController
        drawerViewController.parentVC = mainViewController

        return mainViewController
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
