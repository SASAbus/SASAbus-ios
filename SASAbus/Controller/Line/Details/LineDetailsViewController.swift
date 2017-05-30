import UIKit

class LineDetailsViewController: UIViewController {

    @IBOutlet weak var containerBuses: UIView!
    @IBOutlet weak var containerMap: UIView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var segmentedBackground: UIView!

    var hairLineImage: UIImageView!

    var lineId: Int = 0
    var vehicle: Int = 0


    init(lineId: Int, vehicle: Int) {
        self.lineId = lineId
        self.vehicle = vehicle

        super.init(nibName: "LineDetailsViewController", bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if lineId == 0 {
            fatalError("lineId == 0")
        }

        segmentedBackground.backgroundColor = Color.materialIndigo500

        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if childView is UIImageView && childView.bounds.height <= 1 {
                    hairLineImage = childView as! UIImageView
                }
            }
        }

        prepareBusesViewController()
        prepareMapViewController()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.materialIndigo500
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

            hairLineImage.alpha = 0
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.materialOrange500
            navController.navigationBar.isTranslucent = false
            navController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

            hairLineImage.alpha = 1
        }
    }


    func prepareBusesViewController() {
        let controller = LineDetailsBusesViewController(lineId: lineId, vehicle: vehicle)

        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()

        let view = controller.view

        view!.translatesAutoresizingMaskIntoConstraints = true

        containerBuses.addSubview(view!)
        self.addChildViewController(controller)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }
    }

    func prepareMapViewController() {
        let controller = LineDetailsMapViewController(lineId: lineId)

        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()

        let view = controller.view

        view!.translatesAutoresizingMaskIntoConstraints = true

        containerMap.addSubview(view!)
        self.addChildViewController(controller)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }
    }
}
