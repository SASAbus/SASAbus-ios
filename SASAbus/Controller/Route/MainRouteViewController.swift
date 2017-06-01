import UIKit
import Pulley

class MainRouteViewController: MultiplePulleyViewController {

    var searchController: RouteSearchViewController!
    var resultsController: RouteResultsViewController!
    var routeController: RouteRouteViewController!


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(contentViewController: UIViewController) {
        super.init(contentViewController: contentViewController)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("map", value: "Map", comment: "Map")

        self.setupLeftMenuButton()
    }


    // MARK: - Button Handlers

    func setupLeftMenuButton() {
        let leftDrawerButton = UIBarButtonItem(image: UIImage(named: "menu_icon.png")?
                .withRenderingMode(UIImageRenderingMode.alwaysTemplate), style: UIBarButtonItemStyle.plain,
                target: self, action: #selector(leftDrawerButtonPress(_:)))

        leftDrawerButton.tintColor = Theme.white
        leftDrawerButton.accessibilityLabel = NSLocalizedString("Menu", comment: "")

        self.navigationItem.setLeftBarButton(leftDrawerButton, animated: true)
    }

    func leftDrawerButtonPress(_ sender: AnyObject?) {
        self.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
    }


    static func getViewController() -> MainRouteViewController {
        let contentNib = UINib(nibName: "RouteMapViewController", bundle: nil)
        let contentViewController = contentNib.instantiate(withOwner: self)[0] as! RouteMapViewController

        let mainViewController = MainRouteViewController(
                contentViewController: contentViewController
        )


        let searchNib = UINib(nibName: "RouteSearchViewController", bundle: nil)
        let searchViewController = searchNib.instantiate(withOwner: self)[0] as! RouteSearchViewController

        searchViewController.parentVC = mainViewController
        mainViewController.searchController = searchViewController
        mainViewController.addDrawer(searchViewController)


        let resultsNib = UINib(nibName: "RouteResultsViewController", bundle: nil)
        let resultsViewController = resultsNib.instantiate(withOwner: self)[0] as! RouteResultsViewController

        resultsViewController.parentVC = mainViewController
        mainViewController.resultsController = resultsViewController
        mainViewController.addDrawer(resultsViewController)


        let routeNib = UINib(nibName: "RouteRouteViewController", bundle: nil)
        let routeViewController = routeNib.instantiate(withOwner: self)[0] as! RouteRouteViewController
        routeViewController.parentVC = mainViewController

        resultsViewController.parentVC = mainViewController
        mainViewController.routeController = routeViewController
        mainViewController.addDrawer(routeViewController)


        contentViewController.parentVC = mainViewController
        resultsViewController.parentVC = mainViewController

        return mainViewController
    }
}
