import UIKit
import ChameleonFramework

class LineDetailsViewController: UIViewController {

    @IBOutlet weak var containerBuses: UIView!
    @IBOutlet weak var containerMap: UIView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var segmentedBackground: UIView!

    var listController: LineDetailsBusesViewController!
    var mapController: LineDetailsMapViewController!

    var lineId: Int = 0
    var vehicle: Int = 0

    var isFavorite: Bool = false
    var favoritesChanges: Bool = false

    var toolbarColor = Theme.skyBlue
    var tintColor = ContrastColorOf(Theme.skyBlue, returnFlat: true)

    init(lineId: Int, vehicle: Int) {
        self.lineId = lineId
        self.vehicle = vehicle

        super.init(nibName: "LineDetailsViewController", bundle: nil)

        title = Lines.line(id: lineId)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if lineId == 0 {
            fatalError("lineId == 0")
        }

        segmentedBackground.backgroundColor = toolbarColor
        segmentedControl.tintColor = tintColor

        prepareBusesViewController()
        prepareMapViewController()

        isFavorite = UserRealmHelper.hasFavoriteLine(lineId: lineId)

        let icon: UIImage!
        if isFavorite {
            icon = UIImage(named: "ic_star_white")
        } else {
            icon = UIImage(named: "ic_star_border_white")
        }

        let button = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(toggleFavorite))
        navigationItem.rightBarButtonItem = button
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        if let navController = self.navigationController {
            navController.navigationBar.tintColor = tintColor
            navController.navigationBar.barTintColor = toolbarColor
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: tintColor]
            navController.hidesNavigationBarHairline = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let viewController = navigationController?.viewControllers[0] as? LineViewController
        viewController?.parseData()

        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Theme.orange
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
            navController.hidesNavigationBarHairline = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        listController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerBuses.frame.width, height: containerBuses.frame.height)
        )

        mapController.view.frame = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: containerMap.frame.width, height: containerMap.frame.height)
        )
    }


    @IBAction func showComponent(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.containerBuses.alpha = 1
            self.containerMap.alpha = 0
        } else {
            self.containerBuses.alpha = 0
            self.containerMap.alpha = 1
        }
    }


    func prepareBusesViewController() {
        listController = LineDetailsBusesViewController(lineId: lineId, vehicle: vehicle)
        let view = listController.view

        view!.translatesAutoresizingMaskIntoConstraints = true

        containerBuses.addSubview(view!)
        self.addChildViewController(listController)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }
    }

    func prepareMapViewController() {
        mapController = LineDetailsMapViewController(lineId: lineId)
        let view = mapController.view

        view!.translatesAutoresizingMaskIntoConstraints = true

        containerMap.addSubview(view!)
        self.addChildViewController(mapController)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }
    }

    func toggleFavorite() {
        favoritesChanges = true

        if isFavorite {
            isFavorite = false

            UserRealmHelper.removeFavoriteLine(lineId: lineId)

            navigationItem.rightBarButtonItem?.image = UIImage(named: "ic_star_border_white")
        } else {
            isFavorite = true

            UserRealmHelper.addFavoriteLine(lineId: lineId)

            navigationItem.rightBarButtonItem?.image = UIImage(named: "ic_star_white")
        }
    }
}
