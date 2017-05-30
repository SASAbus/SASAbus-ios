import UIKit

class MainMapViewController: PulleyViewController {

    var activityIndicator: UIActivityIndicatorView?

    let DRAWER_HEIGHT: CGFloat = 380

    var height: CGFloat = 0
    var totalHeight: CGFloat = 0
    var totalWidth: CGFloat = 0

    var didLayoutImage: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }


    static func getViewController() -> MainMapViewController {
        // var contentViewController = RealtimeMapViewController(nibName: "RealtimeMapViewController", bundle: nil)
        // var drawerViewController = BottomSheetViewController(nibName: "BottomSheetViewController", bundle: nil)

        let contentNib = UINib(nibName: "RealtimeMapViewController", bundle:nil)
        let contentViewController = contentNib.instantiate(withOwner: self)[0] as! RealtimeMapViewController

        let drawerNib = UINib(nibName: "BottomSheetViewController", bundle:nil)
        let drawerViewController = drawerNib.instantiate(withOwner: self)[0] as! BottomSheetViewController

        let mainViewController = MainMapViewController(
                contentViewController: contentViewController,
                drawerViewController: drawerViewController
        )

        contentViewController.parentVC = mainViewController
        drawerViewController.parentVC = mainViewController

        return mainViewController
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("map", value: "Map", comment: "Map")

        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        let activityButton = UIBarButtonItem(customView: activityIndicator!)

        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.refresh,
            target: self,
            action: #selector(parseData(sender:))
        )

        navigationItem.rightBarButtonItems = [refreshButton, activityButton]

        backgroundImage.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        if !didLayoutImage {
            calculateViews()
        }

        super.viewDidLayoutSubviews()

        setDrawerPosition(position: drawerPosition, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /* else if segue.identifier == "segue_map_bus_details" {
            let bus = sender as! RealtimeBus
            let viewController = segue.destination as! BusDetailsViewController

            viewController.vehicleId = bus.vehicle
        } else if segue.identifier == "segue_map_line_details" {
            let bus = sender as! RealtimeBus
            let viewController = segue.destination as! LineDetailsViewController

            viewController.lineId = bus.line
        } else if segue.identifier == "segue_map_line_course" {
            let bus = sender as! RealtimeBus
            let viewController = segue.destination as! LineCourseViewController

            viewController.vehicle = bus.vehicle
            viewController.lineId = bus.line
        }*/
    }


    func calculateViews() {
        didLayoutImage = true

        totalHeight = view.frame.size.height
        totalWidth = view.frame.size.width

        if DRAWER_HEIGHT > totalHeight {
            topInset = 0
        } else {
            topInset = totalHeight - DRAWER_HEIGHT
        }

        let imageHeight = topInset

        height = CGFloat(totalHeight) - CGFloat(80)

        let imageFrame = CGRect(x: 0, y: 0, width: totalWidth, height: imageHeight)

        backgroundImage.frame = imageFrame
    }

    func setImagePosition(offset: CGFloat) {
        if offset <= 0 {
            backgroundImage.isHidden = true
        } else {
            backgroundImage.isHidden = false
        }

        let newOffset = totalHeight - (offset * CGFloat(height)) - 80

        backgroundImage.frame.origin.y = newOffset
    }

    func parseData(sender: UIBarButtonItem) {
        let mapViewController = childViewControllers[0] as! RealtimeMapViewController
        mapViewController.parseData()
    }
}
