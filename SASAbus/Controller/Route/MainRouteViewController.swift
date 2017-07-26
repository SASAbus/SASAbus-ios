import UIKit
import Pulley

class MainRouteViewController: MasterViewController {

    @IBOutlet var searchContainer: UIView!
    @IBOutlet var resultsContainer: UIView!

    private var shadowImageView: UIImageView?


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init() {
        super.init(nibName: "MainRouteViewController", title: "Route")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        let searchNib = UINib(nibName: "RouteFeedViewController", bundle: nil)
        let searchViewController = searchNib.instantiate(withOwner: self)[0] as! RouteFeedViewController
        searchViewController.parentVC = self

        let resultsViewController = RouteResultsViewController.getViewController()
        resultsViewController.parentVC = self

        addChildController(searchViewController, container: searchContainer)
        addChildController(resultsViewController, container: resultsContainer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if shadowImageView == nil {
            shadowImageView = findShadowImage(under: navigationController!.navigationBar)
        }

        shadowImageView?.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        shadowImageView?.isHidden = false
    }


    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }

        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }

        return nil
    }
}
