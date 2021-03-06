import UIKit

/**
 *  The base delegate protocol for Pulley delegates.
 */

@objc protocol BottomSheetDelegate: class {
    @objc optional func drawerPositionDidChange(drawer: BottomSheetViewController)

    @objc optional func makeUIAdjustmentsForFullscreen(progress: CGFloat)

    @objc optional func offsetChanged(distance: CGFloat, offset: CGFloat)
}

/**
 *  View controllers in the drawer can implement this to receive changes in state or provide values for the different drawer positions.
 */

@objc protocol BottomSheetDrawerViewControllerDelegate: BottomSheetDelegate {
    func collapsedDrawerHeight() -> CGFloat

    func partialRevealDrawerHeight() -> CGFloat
}

/**
 *  View controllers that are the main content can implement this to receive changes in state.
 */

@objc protocol BottomSheetPrimaryContentControllerDelegate: BottomSheetDelegate {

    // Not currently used for anything, but it's here for parity with the hopes that it'll one day be used.
}

/**
 Represents a Pulley drawer position.
 
 - Collapsed:         When the drawer is in its smallest form, at the bottom of the screen.
 - PartiallyRevealed: When the drawer is partially revealed.
 - Open:              When the drawer is fully open.
 */

public enum BottomSheetPosition {
    case collapsed
    case partiallyRevealed
    case open
}

private let kPulleyDefaultCollapsedHeight: CGFloat = 68.0
private let kPulleyDefaultPartialRevealHeight: CGFloat = 264.0

class BottomSheetViewController: MasterViewController, UIScrollViewDelegate, BottomSheetPassthroughScrollViewDelegate {

    // Interface Builder

    /// When using with Interface Builder only! Connect a containing view to this outlet.
    @IBOutlet var primaryContentContainerView: UIView!

    /// When using with Interface Builder only! Connect a containing view to this outlet.
    @IBOutlet var drawerContentContainerView: UIView!

    var backgroundImage: UIImageView! = UIImageView()

    // Internal
    private let primaryContentContainer: UIView = UIView()
    private let drawerContentContainer: UIView = UIView()
    private let drawerShadowView: UIView = UIView()
    public let drawerScrollView: BottomSheetPassthroughScrollView = BottomSheetPassthroughScrollView()
    private let backgroundDimmingView: UIView = UIView()

    private var dimmingViewTapRecognizer: UITapGestureRecognizer?

    /// The current content view controller (shown behind the drawer).
    private(set) var primaryContentViewController: UIViewController! {
        willSet {
            guard let controller = primaryContentViewController else {
                return
            }

            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }

        didSet {
            guard let controller = primaryContentViewController else {
                return
            }

            let view = controller.view

            view!.translatesAutoresizingMaskIntoConstraints = true

            self.primaryContentContainer.addSubview(view!)
            self.addChildViewController(controller)

            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    /// The current drawer view controller (shown in the drawer).
    private(set) var drawerContentViewController: UIViewController! {
        willSet {
            guard let controller = drawerContentViewController else {
                return
            }

            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }

        didSet {
            guard let controller = drawerContentViewController else {
                return
            }

            controller.view.translatesAutoresizingMaskIntoConstraints = true

            self.drawerContentContainer.addSubview(controller.view)
            self.addChildViewController(controller)

            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    // The content view controller and drawer controller can receive delegate events already.
    // This lets another object observe the changes, if needed.
    public weak var delegate: BottomSheetDelegate?

    // The current position of the drawer.
    public private(set) var drawerPosition: BottomSheetPosition = .collapsed

    // The inset from the top of the view controller when fully open.
    public var topInset: CGFloat = 200 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    // The corner radius for the drawer.
    public var drawerCornerRadius: CGFloat = 0 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    // The opacity of the drawer shadow.
    public var shadowOpacity: Float = 0.1 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    // The radius of the drawer shadow.
    public var shadowRadius: CGFloat = 3.0 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    // The opaque color of the background dimming view.
    public var backgroundDimmingColor: UIColor = UIColor.black {
        didSet {
            if self.isViewLoaded {
                backgroundDimmingView.backgroundColor = backgroundDimmingColor
            }
        }
    }

    // The maximum amount of opacity when dimming.
    public var backgroundDimmingOpacity: CGFloat = 0.5 {
        didSet {
            if self.isViewLoaded {
                self.scrollViewDidScroll(drawerScrollView)
            }
        }
    }

    /**
     Initialize the drawer controller programmtically.
     
     - parameter contentViewController: The content view controller. This view controller is shown behind the drawer.
     - parameter drawerViewController:  The view controller to display inside the drawer.
     
     - note: The drawer VC is 20pts too tall in order to have some extra space for the bounce animation. 
     Make sure your constraints / content layout take this into account.
     
     - returns: A newly created Pulley drawer.
     */
    required public init(contentViewController: UIViewController, drawerViewController: UIViewController) {
        super.init(nibName: nil, title: nil)

        ({
            self.primaryContentViewController = contentViewController
            self.drawerContentViewController = drawerViewController
        })()
    }

    /**
     Initialize the drawer controller from Interface Builder.
     
     - note: Usage notes: Make 2 container views in Interface Builder and connect their
     outlets to -primaryContentContainerView and -drawerContentContainerView.
     Then use embed segues to place your content/drawer view controllers into the appropriate container.
     
     - parameter aDecoder: The NSCoder to decode from.
     
     - returns: A newly created Pulley drawer.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func loadView() {
        super.loadView()

        // IB Support
        if primaryContentContainerView != nil {
            primaryContentContainerView.removeFromSuperview()
        }

        if drawerContentContainerView != nil {
            drawerContentContainerView.removeFromSuperview()
        }

        // Setup
        primaryContentContainer.backgroundColor = UIColor.white

        drawerScrollView.bounces = false
        drawerScrollView.delegate = self
        drawerScrollView.clipsToBounds = false
        drawerScrollView.showsVerticalScrollIndicator = false
        drawerScrollView.showsHorizontalScrollIndicator = false
        drawerScrollView.delaysContentTouches = true
        drawerScrollView.canCancelContentTouches = true
        drawerScrollView.backgroundColor = UIColor.clear
        drawerScrollView.decelerationRate = UIScrollViewDecelerationRateFast
        drawerScrollView.touchDelegate = self

        drawerShadowView.layer.shadowOpacity = shadowOpacity
        drawerShadowView.layer.shadowRadius = shadowRadius
        drawerShadowView.backgroundColor = UIColor.clear

        drawerContentContainer.backgroundColor = UIColor.clear

        backgroundDimmingView.backgroundColor = backgroundDimmingColor
        backgroundDimmingView.isUserInteractionEnabled = false
        backgroundDimmingView.alpha = 0.0

        dimmingViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapRecognizerAction(gestureRecognizer:)))
        backgroundDimmingView.addGestureRecognizer(dimmingViewTapRecognizer!)

        drawerScrollView.addSubview(drawerShadowView)
        drawerScrollView.addSubview(drawerContentContainer)

        primaryContentContainer.backgroundColor = UIColor.white

        self.view.backgroundColor = UIColor.white

        backgroundImage.contentMode = .scaleAspectFill

        self.view.addSubview(primaryContentContainer)
        self.view.addSubview(backgroundDimmingView)
        self.view.addSubview(backgroundImage)
        self.view.addSubview(drawerScrollView)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // IB Support
        if primaryContentViewController == nil || drawerContentViewController == nil {
            assert(primaryContentContainerView != nil && drawerContentContainerView != nil,
                    "When instantiating from Interface Builder you must provide container views with an embedded view controller.")

            // Locate main content VC
            for child in self.childViewControllers {
                if child.view == primaryContentContainerView.subviews.first {
                    primaryContentViewController = child
                }

                if child.view == drawerContentContainerView.subviews.first {
                    drawerContentViewController = child
                }
            }

            assert(primaryContentViewController != nil && drawerContentViewController != nil,
                    "Container views must contain an embedded view controller.")
        }

        scrollViewDidScroll(drawerScrollView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Layout main content
        primaryContentContainer.frame = self.view.bounds
        backgroundDimmingView.frame = self.view.bounds

        // Layout scrollview
        drawerScrollView.frame = CGRect(x: 0, y: topInset, width: self.view.bounds.width, height: self.view.bounds.height - topInset)

        // Layout container
        var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight
        var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight

        if let drawerVCCompliant = drawerContentViewController as? BottomSheetDrawerViewControllerDelegate {
            collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
            partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()
        }

        let lowestStop = [(self.view.bounds.size.height - topInset), collapsedHeight, partialRevealHeight].min() ?? 0
        let bounceOverflowMargin: CGFloat = 20

        drawerContentContainer.frame = CGRect(x: 0, y: drawerScrollView.bounds.height - lowestStop,
                width: drawerScrollView.bounds.width, height: drawerScrollView.bounds.height + bounceOverflowMargin)
        drawerShadowView.frame = drawerContentContainer.frame
        drawerScrollView.contentSize = CGSize(width: drawerScrollView.bounds.width,
                height: (drawerScrollView.bounds.height - lowestStop) + drawerScrollView.bounds.height)

        // Update rounding mask and shadows
        let borderPath = UIBezierPath(roundedRect: drawerContentContainer.bounds,
                byRoundingCorners: [.topLeft, .topRight], cornerRadii:
        CGSize(width: drawerCornerRadius, height: drawerCornerRadius)).cgPath

        let cardMaskLayer = CAShapeLayer()
        cardMaskLayer.path = borderPath
        cardMaskLayer.fillColor = UIColor.white.cgColor
        cardMaskLayer.backgroundColor = UIColor.clear.cgColor

        drawerContentContainer.layer.mask = cardMaskLayer
        drawerShadowView.layer.shadowPath = borderPath

        // Make VC views match frames
        primaryContentViewController.view.frame = primaryContentContainer.bounds
        drawerContentViewController.view.frame = CGRect(
                x: drawerContentContainer.bounds.minX,
                y: drawerContentContainer.bounds.minY,
                width: drawerContentContainer.bounds.width,
                height: drawerContentContainer.bounds.height
        )
    }


    // MARK: Configuration Updates

    /**
     Set the drawer position, with an option to animate.
     
     - parameter position: The position to set the drawer to.
     - parameter animated: Whether or not to animate the change. (Default: true)
     */
    public func setDrawerPosition(position: BottomSheetPosition, animated: Bool = true) {
        drawerPosition = position

        var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight
        var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight

        if let drawerVCCompliant = drawerContentViewController as? BottomSheetDrawerViewControllerDelegate {
            collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
            partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()
        }

        let stopToMoveTo: CGFloat

        switch drawerPosition {
        case .collapsed:
            stopToMoveTo = collapsedHeight
        case .partiallyRevealed:
            stopToMoveTo = partialRevealHeight
        case .open:
            stopToMoveTo = (self.view.bounds.size.height - topInset)
        }

        let drawerStops = [(self.view.bounds.size.height - topInset), collapsedHeight, partialRevealHeight]
        let lowestStop = drawerStops.min() ?? 0

        if animated {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: { [weak self] () -> Void in
                self?.drawerScrollView.setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)

                if let drawer = self {
                    drawer.delegate?.drawerPositionDidChange?(drawer: drawer)
                    (drawer.drawerContentViewController as? BottomSheetDrawerViewControllerDelegate)?.drawerPositionDidChange?(drawer: drawer)
                    (drawer.primaryContentViewController as? BottomSheetPrimaryContentControllerDelegate)?.drawerPositionDidChange?(drawer: drawer)

                    drawer.view.layoutIfNeeded()
                }
            }, completion: nil)
        } else {
            drawerScrollView.setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)

            delegate?.drawerPositionDidChange?(drawer: self)
            (drawerContentViewController as? BottomSheetDrawerViewControllerDelegate)?.drawerPositionDidChange?(drawer: self)
            (primaryContentViewController as? BottomSheetPrimaryContentControllerDelegate)?.drawerPositionDidChange?(drawer: self)
        }
    }

    /**
     Change the current primary content view controller (The one behind the drawer)
     
     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change. Defaults to true.
     */
    public func setPrimaryContentViewController(controller: UIViewController, animated: Bool = true) {
        if animated {
            UIView.transition(with: primaryContentContainer, duration: 0.5, options:
            UIViewAnimationOptions.transitionCrossDissolve, animations: { [weak self] () -> Void in

                self?.primaryContentViewController = controller
            }, completion: nil)
        } else {
            primaryContentViewController = controller
        }
    }

    /**
     Change the current drawer content view controller (The one inside the drawer)
     
     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change.
     */
    public func setDrawerContentViewController(controller: UIViewController, animated: Bool = true) {
        if animated {
            UIView.transition(with: drawerContentContainer, duration: 0.5, options:
            UIViewAnimationOptions.transitionCrossDissolve, animations: { [weak self] () -> Void in

                self?.drawerContentViewController = controller
                self?.setDrawerPosition(position: self?.drawerPosition ?? .collapsed, animated: false)
            }, completion: nil)
        } else {
            drawerContentViewController = controller
            setDrawerPosition(position: drawerPosition, animated: false)
        }
    }

    // MARK: Actions

    func dimmingViewTapRecognizerAction(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer == dimmingViewTapRecognizer {
            if gestureRecognizer.state == .began {
                self.setDrawerPosition(position: .collapsed, animated: true)
            }
        }
    }

    // MARK: UIScrollViewDelegate

    private var lastDragTargetContentOffset: CGPoint = CGPoint.zero

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == drawerScrollView {
            // Find the closest anchor point and snap there.
            var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight
            var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight

            if let drawerVCCompliant = drawerContentViewController as? BottomSheetDrawerViewControllerDelegate {
                collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
                partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()
            }

            let drawerStops = [(self.view.bounds.size.height - topInset), collapsedHeight, partialRevealHeight]
            let lowestStop = drawerStops.min() ?? 0

            let distanceFromBottomOfView = lowestStop + lastDragTargetContentOffset.y

            var currentClosestStop = lowestStop

            for currentStop in drawerStops {
                if abs(currentStop - distanceFromBottomOfView) < abs(currentClosestStop - distanceFromBottomOfView) {
                    currentClosestStop = currentStop
                }
            }

            if abs(Float(currentClosestStop - (self.view.bounds.size.height - topInset))) <= Float.ulpOfOne {
                setDrawerPosition(position: .open, animated: true)
            } else if abs(Float(currentClosestStop - collapsedHeight)) <= Float.ulpOfOne {
                setDrawerPosition(position: .collapsed, animated: true)
            } else {
                setDrawerPosition(position: .partiallyRevealed, animated: true)
            }
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if scrollView == drawerScrollView {
            lastDragTargetContentOffset = targetContentOffset.pointee

            // Halt intertia
            targetContentOffset.pointee = scrollView.contentOffset
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == drawerScrollView {
            var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight
            var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight

            if let drawerVCCompliant = drawerContentViewController as? BottomSheetDrawerViewControllerDelegate {
                collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
                partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()
            }

            let drawerStops = [(self.view.bounds.size.height - topInset), collapsedHeight, partialRevealHeight]
            let lowestStop = drawerStops.min() ?? 0

            var progress: CGFloat = 0

            if scrollView.contentOffset.y > partialRevealHeight - lowestStop {
                // Calculate percentage between partial and full reveal
                let fullRevealHeight = (self.view.bounds.size.height - topInset)

                progress = (scrollView.contentOffset.y - (partialRevealHeight - lowestStop)) / (fullRevealHeight - (partialRevealHeight))

                delegate?.makeUIAdjustmentsForFullscreen?(progress: progress)
                (drawerContentViewController as? BottomSheetDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress)
                (primaryContentViewController as? BottomSheetPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress)

                backgroundDimmingView.alpha = progress * backgroundDimmingOpacity

                backgroundDimmingView.isUserInteractionEnabled = true
            } else {
                if backgroundDimmingView.alpha >= 0.001 {
                    backgroundDimmingView.alpha = 0.0

                    delegate?.makeUIAdjustmentsForFullscreen?(progress: 0.0)
                    (drawerContentViewController as? BottomSheetDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0)
                    (primaryContentViewController as? BottomSheetPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0)

                    backgroundDimmingView.isUserInteractionEnabled = false
                }
            }

            delegate?.offsetChanged?(distance: scrollView.contentOffset.y + lowestStop, offset: progress)

            (drawerContentViewController as? BottomSheetDrawerViewControllerDelegate)?
                    .offsetChanged?(distance: scrollView.contentOffset.y + lowestStop, offset: progress)

            (primaryContentViewController as? BottomSheetPrimaryContentControllerDelegate)?
                    .offsetChanged?(distance: scrollView.contentOffset.y + lowestStop, offset: progress)
        }
    }

    // MARK: Touch Passthrough ScrollView Delegate

    func shouldTouchPassthroughScrollView(scrollView: BottomSheetPassthroughScrollView, point: CGPoint) -> Bool {
        let contentDrawerLocation = drawerContentContainer.frame.origin.y

        if point.y < contentDrawerLocation {
            return true
        }

        return false
    }

    func viewToReceiveTouch(scrollView: BottomSheetPassthroughScrollView) -> UIView {
        if drawerPosition == .open {
            return backgroundDimmingView
        }

        return primaryContentContainer
    }
}
