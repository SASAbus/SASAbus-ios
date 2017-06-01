import UIKit

/**
 *  The base delegate protocol for Pulley delegates.
 */

@objc public protocol PulleyDelegate: class {

    @objc optional func drawerPositionDidChange(drawer: MultiplePulleyViewController)

    @objc optional func makeUIAdjustmentsForFullscreen(progress: CGFloat)

    @objc optional func drawerChangedDistanceFromBottom(drawer: MultiplePulleyViewController, distance: CGFloat)
}

/**
 *  View controllers in the drawer can implement this to receive changes in state or provide values for the different drawer positions.
 */

public protocol PulleyDrawerViewControllerDelegate: PulleyDelegate {

    func collapsedDrawerHeight() -> CGFloat

    func drawerIndex() -> Int

    func initialPosition() -> PulleyPosition
}

/**
 *  View controllers that are the main content can implement this to receive changes in state.
 */

public protocol PulleyPrimaryContentControllerDelegate: PulleyDelegate {
    // Not currently used for anything, but it's here for parity with the hopes that it'll one day be used.
}

/**
 *  A completion block used for animation callbacks.
 */

public typealias PulleyAnimationCompletionBlock = ((_ finished: Bool) -> Void)

/**
 Represents a Pulley drawer position.

 - collapsed:         When the drawer is in its smallest form, at the bottom of the screen.
 - open:              When the drawer is fully open.
 - closed:            When the drawer is off-screen at the bottom of the view. Note: Users cannot close or reopen
                      the drawer on their own. You must set this programmatically
 */

public enum PulleyPosition: Int {

    case collapsed = 0
    case open = 2
    case closed = 3

    public static let all: [PulleyPosition] = [
            .collapsed,
            .open,
            .closed
    ]

    public static func positionFor(string: String?) -> PulleyPosition {
        guard let positionString = string?.lowercased() else {
            return .collapsed
        }

        switch positionString {
        case "collapsed":
            return .collapsed
        case "open":
            return .open
        case "closed":
            return .closed
        default:
            fatalError("PulleyViewController: Position for string '\(positionString)' not found. " +
                    "Available values are: collapsed, open, and closed.")
        }
    }
}


open class MultiplePulleyViewController: UIViewController {

    fileprivate var drawerCount = 0

    fileprivate let primaryContentContainer: UIView = UIView()

    fileprivate var drawerContentContainer: [UIView] = []

    fileprivate var drawerShadowView: [UIView] = []
    fileprivate var drawerScrollView: [PulleyPassthroughScrollView] = []

    fileprivate var backgroundDimmingView = UIView()
    fileprivate var dimmingViewTapRecognizer: UITapGestureRecognizer?

    fileprivate var lastDragTargetContentOffset: [CGPoint] = []


    /// The current content view controller (shown behind the drawer).
    public fileprivate(set) var primaryContentViewController: UIViewController! {
        willSet {

            guard let controller = primaryContentViewController else {
                return
            }

            controller.view.removeFromSuperview()
            controller.willMove(toParentViewController: nil)
            controller.removeFromParentViewController()
        }

        didSet {

            guard let controller = primaryContentViewController else {
                return
            }

            controller.view.translatesAutoresizingMaskIntoConstraints = true

            self.primaryContentContainer.addSubview(controller.view)
            self.addChildViewController(controller)
            controller.didMove(toParentViewController: self)

            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    public fileprivate(set) var drawerContentViewController: [UIViewController] = []


    // The content view controller and drawer controller can receive delegate events already.
    // This lets another object observe the changes, if needed.
    public weak var delegate: PulleyDelegate?


    /// The current position of the drawer.
    public fileprivate(set) var drawerPosition: [PulleyPosition] = [] {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }


    /// The background visual effect layer for the drawer. By default this is the extraLight effect.
    /// You can change this if you want, or assign nil to remove it.
    public var drawerBackgroundVisualEffectView: [UIVisualEffectView?] = [] {
        willSet {
            drawerBackgroundVisualEffectView.forEach {
                $0?.removeFromSuperview()
            }
        }
        didSet {
            for i in 0..<drawerCount {
                if let visualEffect = drawerBackgroundVisualEffectView[i], self.isViewLoaded {
                    drawerScrollView[i].insertSubview(visualEffect, aboveSubview: drawerShadowView[i])

                    visualEffect.clipsToBounds = true
                    visualEffect.layer.cornerRadius = drawerCornerRadius
                }
            }
        }
    }


    /// The inset from the top of the view controller when fully open.
    @IBInspectable public var topInset: CGFloat = 50 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    /// The corner radius for the drawer.
    @IBInspectable public var drawerCornerRadius: CGFloat = 10 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()

                for i in 0..<drawerCount {
                    drawerBackgroundVisualEffectView[i]?.layer.cornerRadius = drawerCornerRadius
                }
            }
        }
    }

    /// The opacity of the drawer shadow.
    @IBInspectable public var shadowOpacity: Float = 0.1 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    /// The radius of the drawer shadow.
    @IBInspectable public var shadowRadius: CGFloat = 3 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    /// The opaque color of the background dimming view.
    @IBInspectable public var backgroundDimmingColor: UIColor = UIColor.black {
        didSet {
            if self.isViewLoaded {
                backgroundDimmingView.backgroundColor = backgroundDimmingColor
            }
        }
    }

    /// The maximum amount of opacity when dimming.
    @IBInspectable public var backgroundDimmingOpacity: CGFloat = 0.5 {
        didSet {
            if self.isViewLoaded {
                for i in 0..<drawerCount {
                    self.scrollViewDidScroll(drawerScrollView[i])
                }
            }
        }
    }

    public var animationDuration = 0.75


    /**
     Initialize the drawer controller programmatically.

     - parameter contentViewController: The content view controller. This view controller is shown behind the drawer.
     - parameter drawerViewController:  The view controller to display inside the drawer.

     - note: The drawer VC is 20pts too tall in order to have some extra space for the bounce animation.
             Make sure your constraints / content layout take this into account.

     - returns: A newly created Pulley drawer.
     */
    required public init(contentViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)

        ({
            self.primaryContentViewController = contentViewController
        })()
    }

    /**
     Initialize the drawer controller from Interface Builder.

     - note: Usage notes: Make 2 container views in Interface Builder and connect their outlets to -primaryContentContainerView and -drawerContentContainerView. Then use embed segues to place your content/drawer view controllers into the appropriate container.

     - parameter aDecoder: The NSCoder to decode from.

     - returns: A newly created Pulley drawer.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override open func loadView() {
        super.loadView()

        // Setup
        primaryContentContainer.backgroundColor = UIColor.white

        definesPresentationContext = true

        for i in 0..<drawerCount {
            drawerBackgroundVisualEffectView[i]?.clipsToBounds = true
        }

        primaryContentContainer.backgroundColor = UIColor.white

        backgroundDimmingView.backgroundColor = backgroundDimmingColor
        backgroundDimmingView.isUserInteractionEnabled = false
        backgroundDimmingView.alpha = 0.0

        let selector = #selector(MultiplePulleyViewController.dimmingViewTapRecognizerAction(gestureRecognizer:))
        dimmingViewTapRecognizer = UITapGestureRecognizer(target: self, action: selector)

        backgroundDimmingView.addGestureRecognizer(dimmingViewTapRecognizer!)

        self.view.backgroundColor = UIColor.white

        self.view.addSubview(primaryContentContainer)
        self.view.addSubview(backgroundDimmingView)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        for scrollView in drawerScrollView {
            scrollViewDidScroll(scrollView)
        }
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Layout main content
        primaryContentContainer.frame = self.view.bounds
        backgroundDimmingView.frame = self.view.bounds

        for i in 0..<drawerCount {
            let drawer = drawerContentViewController[i] as! PulleyDrawerViewControllerDelegate
            let collapsedHeight = drawer.collapsedDrawerHeight()

            let lowestStop = [(self.view.bounds.size.height - topInset), collapsedHeight].min() ?? 0
            let bounceOverflowMargin: CGFloat = 20.0

            // Layout ScrollView
            drawerScrollView[i].frame = CGRect(
                    x: 0,
                    y: topInset,
                    width: self.view.bounds.width,
                    height: self.view.bounds.height - topInset
            )

            drawerContentContainer[i].frame = CGRect(
                    x: 0,
                    y: drawerScrollView[i].bounds.height - lowestStop,
                    width: drawerScrollView[i].bounds.width,
                    height: drawerScrollView[i].bounds.height + bounceOverflowMargin
            )

            drawerBackgroundVisualEffectView[i]?.frame = drawerContentContainer[i].frame
            drawerShadowView[i].frame = drawerContentContainer[i].frame

            drawerScrollView[i].contentSize = CGSize(
                    width: drawerScrollView[i].bounds.width,
                    height: (drawerScrollView[i].bounds.height - lowestStop) + drawerScrollView[i].bounds.height
            )

            // Update rounding mask and shadows
            let borderPath = UIBezierPath(
                    roundedRect: drawerContentContainer[i].bounds,
                    byRoundingCorners: [.topLeft, .topRight],
                    cornerRadii: CGSize(width: drawerCornerRadius, height: drawerCornerRadius)
            ).cgPath

            let cardMaskLayer = CAShapeLayer()
            cardMaskLayer.path = borderPath
            cardMaskLayer.frame = drawerContentContainer[i].bounds
            cardMaskLayer.fillColor = UIColor.white.cgColor
            cardMaskLayer.backgroundColor = UIColor.clear.cgColor

            drawerContentContainer[i].layer.mask = cardMaskLayer
            drawerShadowView[i].layer.shadowPath = borderPath

            // Make VC views match frames
            primaryContentViewController?.view.frame = primaryContentContainer.bounds

            drawerContentViewController[i].view.frame = CGRect(
                    x: drawerContentContainer[i].bounds.minX,
                    y: drawerContentContainer[i].bounds.minY,
                    width: drawerContentContainer[i].bounds.width,
                    height: drawerContentContainer[i].bounds.height
            )

            setDrawerPosition(position: drawerPosition[i], animated: false, index: i)
        }
    }


    public func addDrawer(_ controller: UIViewController) {
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        drawerContentViewController.append(controller)

        let contentContainer = UIView()
        contentContainer.backgroundColor = UIColor.clear
        drawerContentContainer.append(contentContainer)

        self.drawerContentContainer.last!.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)

        let pulleyDrawer = controller as! PulleyDrawerViewControllerDelegate
        let initialPosition = pulleyDrawer.initialPosition()

        drawerPosition.append(initialPosition)

        // Scroll view
        let scrollView = PulleyPassthroughScrollView()
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.scrollsToTop = false
        scrollView.touchDelegate = self
        drawerScrollView.append(scrollView)


        // Shadow view
        let shadowView = UIView()
        shadowView.layer.shadowOpacity = shadowOpacity
        shadowView.layer.shadowRadius = shadowRadius
        shadowView.backgroundColor = UIColor.clear
        drawerShadowView.append(shadowView)
        scrollView.addSubview(shadowView)


        // Visual effect view
        let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        drawerBackgroundVisualEffectView.append(visualEffect)
        visualEffect.layer.cornerRadius = drawerCornerRadius

        scrollView.addSubview(visualEffect)
        scrollView.addSubview(contentContainer)

        self.view.addSubview(scrollView)

        lastDragTargetContentOffset.append(CGPoint.zero)
        setDrawerPosition(position: initialPosition, animated: false, index: drawerCount)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }

        drawerCount += 1
    }


    // MARK: Configuration Updates

    /**
     Set the drawer position, with an option to animate.

     - parameter position: The position to set the drawer to.
     - parameter animated: Whether or not to animate the change. (Default: true)
     - parameter completion: A block object to be executed when the animation sequence ends. The Bool indicates whether or not the animations actually finished before the completion handler was called. (Default: nil)
     */
    public func setDrawerPosition(position: PulleyPosition, animated: Bool = true, completion: PulleyAnimationCompletionBlock? = nil, index: Int) {
        drawerPosition[index] = position

        let drawerVCCompliant = drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate
        let collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()

        let stopToMoveTo: CGFloat

        switch drawerPosition[index] {
        case .collapsed:
            stopToMoveTo = collapsedHeight
        case .open:
            stopToMoveTo = (self.view.bounds.size.height - topInset)
        case .closed:
            stopToMoveTo = 0
        }

        let drawerStops = [(self.view.bounds.size.height - topInset), collapsedHeight]
        let lowestStop = drawerStops.min() ?? 0

        if animated {
            UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0,
                    options: .curveEaseInOut, animations: { [weak self] () -> Void in

                self?.drawerScrollView[index].setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)

                if let drawer = self {
                    drawer.delegate?.drawerPositionDidChange?(drawer: drawer)

                    (drawer.drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate).drawerPositionDidChange?(drawer: drawer)
                    (drawer.primaryContentViewController as! PulleyPrimaryContentControllerDelegate).drawerPositionDidChange?(drawer: drawer)

                    drawer.view.layoutIfNeeded()
                }

            }, completion: { (completed) in
                completion?(completed)
            })
        } else {
            drawerScrollView[index].setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)

            delegate?.drawerPositionDidChange?(drawer: self)
            (drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate).drawerPositionDidChange?(drawer: self)
            (primaryContentViewController as! PulleyPrimaryContentControllerDelegate).drawerPositionDidChange?(drawer: self)

            completion?(true)
        }
    }


    // MARK: Actions

    func dimmingViewTapRecognizerAction(gestureRecognizer: UITapGestureRecognizer) {
        // TODO: Add tap recognizer?

        /*var index = -1

        for i in 0...dimmingViewTapRecognizer.count - 1 {
            let view = dimmingViewTapRecognizer[i]
            if gestureRecognizer == view {
                index = i
                break
            }
        }

        if index == -1 {
            return
        }

        if gestureRecognizer.state == .ended {
            self.setDrawerPosition(position: .collapsed, animated: true, index: index)
        }*/
    }
}

extension MultiplePulleyViewController: PulleyPassthroughScrollViewDelegate {

    func shouldTouchPassthroughScrollView(scrollView: PulleyPassthroughScrollView, point: CGPoint) -> Bool {
        var index = -1

        for i in 0..<drawerCount where drawerScrollView[i] == scrollView {
            index = i
            break
        }

        guard index != -1 else {
            Log.error("shouldTouchPassthroughScrollView() index == -1")
            return false
        }

        Log.debug("shouldTouchPassthroughScrollView scroll index: \(index)")

        let contentDrawerLocation = drawerContentContainer[index].frame.origin.y

        if point.y < contentDrawerLocation {
            return true
        }

        return false
    }

    func viewToReceiveTouch(scrollView: PulleyPassthroughScrollView) -> UIView {
        var index = -1

        for i in 0..<drawerCount where drawerScrollView[i] == scrollView {
            index = i
            break
        }

        guard index != -1 else {
            Log.error("viewToReceiveTouch() index == -1")
            return primaryContentContainer
        }

        Log.debug("viewToReceiveTouch scroll index: \(index)")

        if drawerPosition[index] == .open {
            return backgroundDimmingView
        }

        return index > 0 ? drawerContentContainer[index - 1] : primaryContentContainer
    }
}

extension MultiplePulleyViewController: UIScrollViewDelegate {

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var index = -1

        for i in 0..<drawerCount where drawerScrollView[i] == scrollView {
            index = i
            break
        }

        guard index != -1 else {
            Log.error("scrollViewDidEndDragging() index == -1")
            return
        }

        let drawerVCCompliant = drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate
        let collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()

        var drawerStops: [CGFloat] = [CGFloat]()
        drawerStops.append((self.view.bounds.size.height - topInset))
        drawerStops.append(collapsedHeight)

        let lowestStop = drawerStops.min() ?? 0

        let distanceFromBottomOfView = lowestStop + lastDragTargetContentOffset[index].y

        var currentClosestStop = lowestStop

        for currentStop in drawerStops {
            if abs(currentStop - distanceFromBottomOfView) < abs(currentClosestStop - distanceFromBottomOfView) {
                currentClosestStop = currentStop
            }
        }

        if abs(Float(currentClosestStop - (self.view.bounds.size.height - topInset))) <= Float.ulpOfOne {
            setDrawerPosition(position: .open, animated: true, index: index)
        } else if abs(Float(currentClosestStop - collapsedHeight)) <= Float.ulpOfOne {
            setDrawerPosition(position: .collapsed, animated: true, index: index)
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        var index = -1

        for i in 0..<drawerCount where drawerScrollView[i] == scrollView {
            index = i
            break
        }

        guard index != -1 else {
            Log.error("scrollViewWillEndDragging() index == -1")
            return
        }

        Log.debug("scrollViewWillEndDragging scroll index: \(index)")

        lastDragTargetContentOffset[index] = targetContentOffset.pointee

        // Halt intertia
        targetContentOffset.pointee = scrollView.contentOffset
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var index = -1

        for i in 0..<drawerCount where drawerScrollView[i] == scrollView {
            index = i
            break
        }

        guard index != -1 else {
            Log.error("scrollViewDidScroll() index == -1")
            return
        }

        let drawerVCCompliant = drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate
        let collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()

        var drawerStops: [CGFloat] = [CGFloat]()
        drawerStops.append((self.view.bounds.size.height - topInset))
        drawerStops.append(collapsedHeight)

        let lowestStop = drawerStops.min() ?? 0

        if scrollView.contentOffset.y > 0 - lowestStop {
            // Calculate percentage between partial and full reveal
            let fullRevealHeight = (self.view.bounds.size.height - topInset)

            let progress = (scrollView.contentOffset.y - (0 - lowestStop)) / (fullRevealHeight - (0))

            delegate?.makeUIAdjustmentsForFullscreen?(progress: progress)

            (drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate).makeUIAdjustmentsForFullscreen?(progress: progress)
            (primaryContentViewController as! PulleyPrimaryContentControllerDelegate).makeUIAdjustmentsForFullscreen?(progress: progress)

            backgroundDimmingView.alpha = progress * backgroundDimmingOpacity
            backgroundDimmingView.isUserInteractionEnabled = true
        } else {
            if backgroundDimmingView.alpha >= 0.001 {
                backgroundDimmingView.alpha = 0.0

                delegate?.makeUIAdjustmentsForFullscreen?(progress: 0.0)

                (drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate).makeUIAdjustmentsForFullscreen?(progress: 0.0)
                (primaryContentViewController as! PulleyPrimaryContentControllerDelegate).makeUIAdjustmentsForFullscreen?(progress: 0.0)

                backgroundDimmingView.isUserInteractionEnabled = false
            }
        }

        delegate?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop)

        (drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate)
                .drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop)

        (primaryContentViewController as! PulleyPrimaryContentControllerDelegate)
                .drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop)
    }
}
