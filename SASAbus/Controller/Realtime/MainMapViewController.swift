import UIKit

class MainMapViewController: BottomSheetViewController {

    var activityIndicator: UIActivityIndicatorView?

    let DRAWER_HEIGHT: CGFloat = UIScreen.main.isPhone5 ? 316 : 380

    var totalHeight: CGFloat = 0

    var didLayoutImage = false
    var imageHidden = true

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(contentViewController: contentViewController, drawerViewController: drawerViewController)
    }


    static func getViewController() -> MainMapViewController {
        let contentNib = UINib(nibName: "MapViewController", bundle: nil)
        let contentViewController = contentNib.instantiate(withOwner: self)[0] as! MapViewController

        let drawerNib = UINib(nibName: "MapBottomSheetViewController", bundle: nil)
        let drawerViewController = drawerNib.instantiate(withOwner: self)[0] as! MapBottomSheetViewController

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

        title = L10n.Map.title

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

    func calculateViews() {
        didLayoutImage = true

        totalHeight = view.frame.size.height

        if DRAWER_HEIGHT > totalHeight {
            topInset = 0
            imageHidden = true
        } else {
            topInset = totalHeight - DRAWER_HEIGHT
            imageHidden = false
        }
        
        let imageHeight = topInset
        let totalDrawerHeight = DRAWER_HEIGHT

        Log.debug("Total height: \(totalHeight)")
        Log.debug("Top inset: \(topInset)")
        Log.debug("Total drawer height: \(totalDrawerHeight)")
        Log.debug("Image height: \(imageHeight)")

        let imageFrame = CGRect(x: 0, y: totalHeight, width: view.frame.size.width, height: imageHeight)

        backgroundImage.frame = imageFrame
        backgroundImage.isHidden = imageHidden
    }

    func setImagePosition(offset: CGFloat) {
        if imageHidden {
            backgroundImage.isHidden = true
        } else {
            if offset <= 0 {
                backgroundImage.isHidden = true
            } else {
                backgroundImage.isHidden = false
            }
        }

        let height = totalHeight - (80 - 24)
        let newOffset = height - (offset * CGFloat(height))
        
        backgroundImage.frame.origin.y = newOffset
    }

    func parseData(sender: UIBarButtonItem) {
        let mapViewController = childViewControllers[0] as! MapViewController
        mapViewController.parseData()
    }

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        Log.warning("Device rotation")
        didLayoutImage = false
    }
}
