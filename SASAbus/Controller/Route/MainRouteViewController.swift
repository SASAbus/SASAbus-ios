import UIKit
import Pulley

class MainRouteViewController: MultiplePulleyViewController {


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

        var drawerNib = UINib(nibName: "RouteBottomSheetViewController", bundle: nil)
        var drawerViewController = drawerNib.instantiate(withOwner: self)[0] as! RouteBottomSheetViewController

        mainViewController.addDrawer(drawerViewController)


        drawerNib = UINib(nibName: "RouteBottomSheetViewController", bundle: nil)
        drawerViewController = drawerNib.instantiate(withOwner: self)[0] as! RouteBottomSheetViewController

        mainViewController.addDrawer(drawerViewController)

        mainViewController.setDrawerPosition(position: .open, index: 0)

        contentViewController.parentVC = mainViewController
        drawerViewController.parentVC = mainViewController

        return mainViewController
    }
}
