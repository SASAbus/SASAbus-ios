import UIKit

class MapBottomSheetViewController: UIViewController, BottomSheetDrawerViewControllerDelegate,
        BottomSheetPrimaryContentControllerDelegate {

    var parentVC: MainMapViewController?

    public let PEEK_HEIGHT: CGFloat = 80

    @IBOutlet weak var peekView: UIView!
    @IBOutlet weak var peekColorView: UIView!
    @IBOutlet weak var peekTitle: UILabel!
    @IBOutlet weak var peekSubtitle: UILabel!
    @IBOutlet weak var peekDelay: UILabel!

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var lineButtonImage: UIImageView!
    @IBOutlet weak var lineButtonView: UIView!

    @IBOutlet weak var vehicleButtonImage: UIImageView!
    @IBOutlet weak var vehicleButtonView: UIView!

    @IBOutlet weak var courseButtonImage: UIImageView!
    @IBOutlet weak var courseButtonView: UIView!

    @IBOutlet weak var delayImage: UIImageView!
    @IBOutlet weak var delayText: UILabel!

    @IBOutlet weak var headingToImage: UIImageView!
    @IBOutlet weak var headingToText: UILabel!

    @IBOutlet weak var updatedImage: UIImageView!
    @IBOutlet weak var updatedText: UILabel!

    @IBOutlet weak var busImage: UIImageView!
    @IBOutlet weak var busText: UILabel!

    @IBOutlet weak var variantImage: UIImageView!
    @IBOutlet weak var variantText: UILabel!

    @IBOutlet weak var tripImage: UIImageView!
    @IBOutlet weak var tripText: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!

    var didFadeToBlue: Bool = false

    var selectedBus: RealtimeBus!


    override func viewDidLoad() {
        super.viewDidLoad()

        lineButtonImage.tint(with: Theme.skyBlue)
        vehicleButtonImage.tint(with: Theme.skyBlue)
        courseButtonImage.tint(with: Theme.skyBlue)

        delayImage.tint(with: UIColor.darkGray)
        headingToImage.tint(with: UIColor.darkGray)
        updatedImage.tint(with: UIColor.darkGray)
        busImage.tint(with: UIColor.darkGray)
        variantImage.tint(with: UIColor.darkGray)
        tripImage.tint(with: UIColor.darkGray)

        peekColorView.alpha = 0

        let tapRecognized = UITapGestureRecognizer(target: self,
                action: #selector(onPeekClick))
        tapRecognized.numberOfTapsRequired = 1

        peekColorView.isUserInteractionEnabled = true
        peekColorView.addGestureRecognizer(tapRecognized)

        peekView.isUserInteractionEnabled = true
        peekView.addGestureRecognizer(tapRecognized)

        let lineClick = UITapGestureRecognizer(target: self, action: #selector(onLineClick))
        lineClick.numberOfTapsRequired = 1

        lineButtonView.isUserInteractionEnabled = true
        lineButtonView.addGestureRecognizer(lineClick)

        let vehicleClick = UITapGestureRecognizer(target: self, action: #selector(onVehicleClick))
        vehicleClick.numberOfTapsRequired = 1

        vehicleButtonView.isUserInteractionEnabled = true
        vehicleButtonView.addGestureRecognizer(vehicleClick)

        let courseClick = UITapGestureRecognizer(target: self, action: #selector(onCourseClick))
        courseClick.numberOfTapsRequired = 1

        courseButtonView.isUserInteractionEnabled = true
        courseButtonView.addGestureRecognizer(courseClick)
    }


    func updateBottomSheet(bus: RealtimeBus) {
        selectedBus = bus

        peekTitle.text = Lines.line(id: (bus.lineId))
        peekSubtitle.text = L10n.General.nowAt(bus.busStopString)

        peekDelay.text = "\(bus.delay)'"

        if didFadeToBlue {
            peekDelay.textColor = UIColor.white
        } else {
            peekDelay.textColor = Color.delay(bus.delay)
        }

        delayText.text = L10n.Map.Sheet.delayed(bus.delay)
        delayText.textColor = Color.delay(bus.delay)

        headingToText.text = L10n.General.headingTo(bus.destinationString)
        updatedText.text = L10n.Map.Sheet.updated(bus.updated_min_ago)

        busText.text = L10n.Map.Sheet.bus(bus.vehicle)
        variantText.text = L10n.Map.Sheet.variant(bus.variant)
        tripText.text = L10n.Map.Sheet.trip(bus.trip)

        if let vehicle = Buses.getBus(id: bus.vehicle) {
            parentVC!.backgroundImage.image = UIImage(named: vehicle.vehicle.code)
        } else {
            Log.error("Vehicle \(bus.vehicle) does not exist")
        }
    }

    func offsetChanged(distance: CGFloat, offset: CGFloat) {
        if selectedBus == nil {
            return
        }

        if distance > PEEK_HEIGHT {
            fadeToBlue()
        } else if distance <= PEEK_HEIGHT {
            fadeToWhite()
        }

        parentVC?.setImagePosition(offset: offset)
    }

    func collapsedDrawerHeight() -> CGFloat {
        return 0
    }

    func partialRevealDrawerHeight() -> CGFloat {
        return PEEK_HEIGHT
    }

    func drawerPositionDidChange(drawer: BottomSheetViewController) {
        scrollView.isScrollEnabled = drawer.drawerPosition == .open
    }

    func fadeToWhite() {
        if !didFadeToBlue {
            return
        }

        didFadeToBlue = false

        self.peekTitle.textColor = UIColor.black
        self.peekSubtitle.textColor = UIColor.darkGray
        self.peekDelay.textColor = Color.delay(selectedBus.delay)
        self.peekColorView.alpha = 0
    }

    func fadeToBlue() {
        if didFadeToBlue {
            return
        }

        didFadeToBlue = true

        self.peekTitle.textColor = UIColor.white
        self.peekSubtitle.textColor = Color.lightWhite
        self.peekDelay.textColor = UIColor.white
        self.peekColorView.alpha = 1
    }


    // MARK: Click handlers

    func onLineClick(gestureRecognizer: UIGestureRecognizer) {
        let viewController = LineDetailsViewController(lineId: selectedBus.lineId, vehicle: selectedBus.vehicle)
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    func onVehicleClick(gestureRecognizer: UIGestureRecognizer) {
        let viewController = BusDetailsViewController(vehicleId: selectedBus.vehicle)
        self.navigationController!.pushViewController(viewController, animated: true)
    }

    func onCourseClick(gestureRecognizer: UIGestureRecognizer) {
        let viewController = LineCourseViewController(
                tripId: selectedBus.trip,
                lineId: selectedBus.lineId,
                vehicle: selectedBus.vehicle,
                currentBusStop: selectedBus.busStop,
                busStopGroup: 0
        )

        self.navigationController!.pushViewController(viewController, animated: true)
    }

    func onPeekClick(gestureRecognizer: UIGestureRecognizer) {
        self.parentVC?.setDrawerPosition(position: .open, animated: true)
    }
}
