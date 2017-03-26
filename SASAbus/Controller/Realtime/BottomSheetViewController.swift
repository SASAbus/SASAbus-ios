import UIKit

class BottomSheetViewController: UIViewController, PulleyDrawerViewControllerDelegate,
        PulleyPrimaryContentControllerDelegate {
    
    var parentVC: MainMapViewController?
    
    let PEEK_HEIGHT: CGFloat = 80
    
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
        
        UIUtils.tintImage(image: lineButtonImage, tint: Color.materialIndigo500)
        UIUtils.tintImage(image: vehicleButtonImage, tint: Color.materialIndigo500)
        UIUtils.tintImage(image: courseButtonImage, tint: Color.materialIndigo500)
        
        UIUtils.tintImage(image: delayImage, tint: UIColor.darkGray)
        UIUtils.tintImage(image: headingToImage, tint: UIColor.darkGray)
        UIUtils.tintImage(image: updatedImage, tint: UIColor.darkGray)
        UIUtils.tintImage(image: busImage, tint: UIColor.darkGray)
        UIUtils.tintImage(image: variantImage, tint: UIColor.darkGray)
        UIUtils.tintImage(image: tripImage, tint: UIColor.darkGray)
        
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
        peekSubtitle.text = "Now at \(bus.busStopString)"
        
        peekDelay.text = "\(bus.delay)'"
        
        if didFadeToBlue {
            peekDelay.textColor = UIColor.white
        } else {
            peekDelay.textColor = Color.color(forDelay: bus.delay)
        }
        
        delayText.text = "\(bus.delay)' delayed"
        delayText.textColor = Color.color(forDelay: bus.delay)
        
        headingToText.text = "Heading to \(bus.destinationString)"
        updatedText.text = "Updated \(bus.updated_min_ago)' ago"
        
        busText.text = "Bus #\(bus.vehicle)"
        variantText.text = "Variant #\(bus.variant)"
        tripText.text = "Trip #\(bus.trip)"
        
        if let vehicle = Buses.getBus(id: bus.vehicle) {
            Log.debug("Loading image \(vehicle.vehicle.code)")

            parentVC!.backgroundImage.image = UIImage(named: vehicle.vehicle.code)
        } else {
            Log.error("Vehicle \(bus.vehicle) does not exist")
        }
    }
    
    func offsetChanged(distance: CGFloat, offset: CGFloat) {
        if distance > PEEK_HEIGHT {
            fadeToBlue()
        } else if distance <= PEEK_HEIGHT {
            fadeToWhite()
        }
        
        parentVC?.setImagePosition(offset: offset)
    }
    
    func collapsedDrawerHeight() -> CGFloat {
        //return 72.0
        return 0
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        //return 264.0
        return PEEK_HEIGHT
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        scrollView.isScrollEnabled = drawer.drawerPosition == .Open
    }
    
    func fadeToWhite() {
        if !didFadeToBlue {
            return
        }
        
        didFadeToBlue = false
        
        self.peekTitle.textColor = UIColor.black
        self.peekSubtitle.textColor = UIColor.darkGray
        self.peekDelay.textColor = Color.color(forDelay: selectedBus.delay)
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
        parentVC?.performSegue(withIdentifier: "segue_map_line_details", sender: selectedBus)
    }
    
    func onVehicleClick(gestureRecognizer: UIGestureRecognizer) {
        parentVC?.performSegue(withIdentifier: "segue_map_bus_details", sender: selectedBus)
    }
    
    func onCourseClick(gestureRecognizer: UIGestureRecognizer) {
        parentVC?.performSegue(withIdentifier: "segue_map_line_course", sender: selectedBus)
    }
    
    func onPeekClick(gestureRecognizer: UIGestureRecognizer) {
        self.parentVC?.setDrawerPosition(position: .Open, animated: true)
    }
}
