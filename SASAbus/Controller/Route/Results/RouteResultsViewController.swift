import UIKit
import LocationPickerViewController
import Pulley

class RouteResultsViewController: PulleyViewController {

    var mapViewController: RouteMapViewController!
    var drawerViewController: RouteBottomSheetViewController!

    var parentVC: MainRouteViewController!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }


    static func getViewController() -> RouteResultsViewController {
        let contentNib = UINib(nibName: "RouteMapViewController", bundle: nil)
        let mapViewController = contentNib.instantiate(withOwner: self)[0] as! RouteMapViewController

        let drawerNib = UINib(nibName: "RouteBottomSheetViewController", bundle: nil)
        let drawerViewController = drawerNib.instantiate(withOwner: self)[0] as! RouteBottomSheetViewController

        let mainViewController = RouteResultsViewController(
                contentViewController: mapViewController,
                drawerViewController: drawerViewController
        )

        drawerViewController.parentVC = mainViewController
        drawerViewController.parentVC = mainViewController
        
        mainViewController.mapViewController = mapViewController
        mainViewController.drawerViewController = drawerViewController

        return mainViewController
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    func showRouteResults(origin: LocationItem, destination: LocationItem) {
        drawerViewController.showLoadingIndicator()
    }
}
