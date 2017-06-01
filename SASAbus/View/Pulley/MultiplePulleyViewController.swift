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

    func partialRevealDrawerHeight() -> CGFloat

    func supportedDrawerPositions() -> [PulleyPosition]
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
 - partiallyRevealed: When the drawer is partially revealed.
 - open:              When the drawer is fully open.
 - closed:            When the drawer is off-screen at the bottom of the view. Note: Users cannot close or reopen
                      the drawer on their own. You must set this programmatically
 */

public enum PulleyPosition: Int {

    case collapsed = 0
    case partiallyRevealed = 1
    case open = 2
    case closed = 3

    public static let all: [PulleyPosition] = [
            .collapsed,
            .partiallyRevealed,
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

        case "partiallyrevealed":
            return .partiallyRevealed

        case "open":
            return .open

        case "closed":
            return .closed

        default:
            print("PulleyViewController: Position for string '\(positionString)' not found. Available values are: " +
                    "collapsed, partiallyRevealed, open, and closed. Defaulting to collapsed.")

            return .collapsed
        }
    }
}

private let kPulleyDefaultCollapsedHeight: CGFloat = 68.0
private let kPulleyDefaultPartialRevealHeight: CGFloat = 264.0

open class MultiplePulleyViewController: UIViewController {

    // Internal
    fileprivate let primaryContentContainer: UIView = UIView()

    fileprivate var drawerContentContainer: [UIView] = []

    fileprivate var drawerShadowView: [UIView] = []
    fileprivate var drawerScrollView: [PulleyPassthroughScrollView] = []
    fileprivate var backgroundDimmingView: [UIView] = []

    fileprivate var dimmingViewTapRecognizer: [UITapGestureRecognizer?] = []

    fileprivate var lastDragTargetContentOffset: [CGPoint] = []

    fileprivate var drawerCount = 0

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

                for i in 0..<drawerCount {
                    self.setNeedsSupportedDrawerPositionsUpdate(index: i)
                }
            }
        }
    }

    /// The current drawer view controller (shown in the drawer).

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
    @IBInspectable public var topInset: CGFloat = 50.0 {
        didSet {
            if self.isViewLoaded {
                self.view.setNeedsLayout()
            }
        }
    }

    /// The corner radius for the drawer.
    @IBInspectable public var drawerCornerRadius: CGFloat = 13.0 {
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
    @IBInspectable public var shadowRadius: CGFloat = 3.0 {
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
                for i in 0..<drawerCount {
                    backgroundDimmingView[i].backgroundColor = backgroundDimmingColor
                }
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

    /// The starting position for the drawer when it first loads
    public var initialDrawerPosition: PulleyPosition = .collapsed

    /// The drawer positions supported by the drawer
    fileprivate var supportedDrawerPositions: [PulleyPosition] = PulleyPosition.all {
        didSet {
            guard self.isViewLoaded else {
                return
            }

            guard supportedDrawerPositions.count > 0 else {
                supportedDrawerPositions = PulleyPosition.all
                return
            }

            self.view.setNeedsLayout()

            for i in 0..<drawerCount {
                if supportedDrawerPositions.contains(drawerPosition[i]) {
                    setDrawerPosition(position: drawerPosition[i], index: i)
                } else {
                    let lowestDrawerState: PulleyPosition = supportedDrawerPositions.min { (pos1, pos2) -> Bool in
                        return pos1.rawValue < pos2.rawValue
                    } ?? .collapsed

                    setDrawerPosition(position: lowestDrawerState, animated: false, index: i)
                }

                drawerScrollView[i].isScrollEnabled = supportedDrawerPositions.count > 1
            }
        }
    }


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


    public func addDrawer(_ controller: UIViewController) {
        drawerContentViewController.append(controller)

        let index = drawerContentViewController.count

        drawerPosition.append(.collapsed)

        let contentContainer = UIView()
        contentContainer.backgroundColor = UIColor.clear
        drawerContentContainer.append(contentContainer)

        controller.view.translatesAutoresizingMaskIntoConstraints = true

        self.drawerContentContainer.last!.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMove(toParentViewController: self)


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


        // Dimming view
        let dimmingView = UIView()
        dimmingView.backgroundColor = backgroundDimmingColor
        dimmingView.isUserInteractionEnabled = false
        dimmingView.alpha = 0.0

        let selector = #selector(MultiplePulleyViewController.dimmingViewTapRecognizerAction(gestureRecognizer:))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: selector)
        dimmingViewTapRecognizer.append(tapRecognizer)

        dimmingView.addGestureRecognizer(tapRecognizer)
        backgroundDimmingView.append(dimmingView)


        scrollView.addSubview(shadowView)

        // Visual effect view
        let visualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        drawerBackgroundVisualEffectView.append(visualEffect)

        scrollView.addSubview(visualEffect)
        visualEffect.layer.cornerRadius = drawerCornerRadius


        scrollView.addSubview(contentContainer)

        lastDragTargetContentOffset.append(CGPoint.zero)


        self.view.addSubview(dimmingView)
        self.view.addSubview(scrollView)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
            self.setNeedsSupportedDrawerPositionsUpdate(index: drawerCount)
        }

        setDrawerPosition(position: initialDrawerPosition, animated: false, index: drawerCount)

        drawerCount += 1
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

        self.view.backgroundColor = UIColor.white
        self.view.addSubview(primaryContentContainer)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<drawerCount {
            setDrawerPosition(position: initialDrawerPosition, animated: false, index: i)
        }

        for scrollView in drawerScrollView {
            scrollViewDidScroll(scrollView)
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        for i in 0..<drawerCount {
            setNeedsSupportedDrawerPositionsUpdate(index: i)
        }
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Layout main content
        primaryContentContainer.frame = self.view.bounds

        for dimmingView in backgroundDimmingView {
            dimmingView.frame = self.view.bounds
        }

        for i in 0..<drawerCount {
            // Layout container
            var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight
            var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight

            let drawerVCCompliant = drawerContentViewController[i] as! PulleyDrawerViewControllerDelegate
            collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
            partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()

            let lowestStop = [(self.view.bounds.size.height - topInset), collapsedHeight, partialRevealHeight].min() ?? 0
            let bounceOverflowMargin: CGFloat = 20.0

            if supportedDrawerPositions.contains(.open) {
                // Layout ScrollView
                drawerScrollView[i].frame = CGRect(x: 0, y: topInset, width: self.view.bounds.width, height: self.view.bounds.height - topInset)
            } else {
                // Layout ScrollView
                let adjustedTopInset = supportedDrawerPositions.contains(.partiallyRevealed) ? partialRevealHeight : collapsedHeight

                drawerScrollView[i].frame = CGRect(
                        x: 0,
                        y: self.view.bounds.height - adjustedTopInset,
                        width: self.view.bounds.width,
                        height: adjustedTopInset
                )
            }

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


    // MARK: Configuration Updates

    /**
     Set the drawer position, with an option to animate.

     - parameter position: The position to set the drawer to.
     - parameter animated: Whether or not to animate the change. (Default: true)
     - parameter completion: A block object to be executed when the animation sequence ends. The Bool indicates whether or not the animations actually finished before the completion handler was called. (Default: nil)
     */
    public func setDrawerPosition(position: PulleyPosition, animated: Bool, completion: PulleyAnimationCompletionBlock? = nil, index: Int) {
        guard supportedDrawerPositions.contains(position) else {

            print(
                    "PulleyViewController: You can't set the drawer position to something not supported by the current " +
                            "view controller contained in the drawer. If you haven't already, you may need to implement " +
                            "the PulleyDrawerViewControllerDelegate."
            )

            return
        }

        drawerPosition[index] = position

        var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight
        var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight

        let drawerVCCompliant = drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate
        collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
        partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()

        let stopToMoveTo: CGFloat

        switch drawerPosition[index] {
        case .collapsed:
            stopToMoveTo = collapsedHeight

        case .partiallyRevealed:
            stopToMoveTo = partialRevealHeight

        case .open:
            stopToMoveTo = (self.view.bounds.size.height - topInset)

        case .closed:
            stopToMoveTo = 0
        }

        let drawerStops = [(self.view.bounds.size.height - topInset), collapsedHeight, partialRevealHeight]
        let lowestStop = drawerStops.min() ?? 0

        if animated {
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0,
                    options: .curveEaseInOut, animations: { [weak self] () -> Void in

                self?.drawerScrollView[index].setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)

                if let drawer = self {
                    drawer.delegate?.drawerPositionDidChange?(drawer: drawer)
                    (drawer.drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerPositionDidChange?(drawer: drawer)
                    (drawer.primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.drawerPositionDidChange?(drawer: drawer)

                    drawer.view.layoutIfNeeded()
                }

            }, completion: { (completed) in
                completion?(completed)
            })
        } else {
            drawerScrollView[index].setContentOffset(CGPoint(x: 0, y: stopToMoveTo - lowestStop), animated: false)

            delegate?.drawerPositionDidChange?(drawer: self)
            (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.drawerPositionDidChange?(drawer: self)
            (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.drawerPositionDidChange?(drawer: self)

            completion?(true)
        }
    }

    /**
     Set the drawer position, the change will be animated.

     - parameter position: The position to set the drawer to.
     */
    public func setDrawerPosition(position: PulleyPosition, index: Int) {
        setDrawerPosition(position: position, animated: true, index: index)
    }

    /**
     Change the current primary content view controller (The one behind the drawer)

     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change. Defaults to true.
     - parameter completion: A block object to be executed when the animation sequence ends. The Bool indicates whether or not the animations actually finished before the completion handler was called.
     */
    public func setPrimaryContentViewController(controller: UIViewController, animated: Bool = true, completion: PulleyAnimationCompletionBlock?) {
        if animated {
            UIView.transition(with: primaryContentContainer, duration: 0.5, options: .transitionCrossDissolve, animations: { [weak self] () -> Void in

                self?.primaryContentViewController = controller

            }, completion: { (completed) in

                completion?(completed)
            })
        } else {
            primaryContentViewController = controller
            completion?(true)
        }
    }

    /**
     Change the current primary content view controller (The one behind the drawer). This method exists for backwards compatibility.

     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change. Defaults to true.
     */
    public func setPrimaryContentViewController(controller: UIViewController, animated: Bool = true) {
        setPrimaryContentViewController(controller: controller, animated: animated, completion: nil)
    }

    /**
     Change the current drawer content view controller (The one inside the drawer)

     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change.
     - parameter completion: A block object to be executed when the animation sequence ends.
                             The Bool indicates whether or not the animations actually finished before
                             the completion handler was called.
     */
    public func setDrawerContentViewController(controller: UIViewController, animated: Bool = true,
                                               completion: PulleyAnimationCompletionBlock?, index: Int) {

        if animated {
            UIView.transition(with: drawerContentContainer[index], duration: 0.5, options: .transitionCrossDissolve,
                    animations: { [weak self] () -> Void in

                        self?.drawerContentViewController[index] = controller
                        self?.setDrawerPosition(position: self?.drawerPosition[index] ?? .collapsed, animated: false, index: index)

                    }, completion: { (completed) in
                completion?(completed)
            })
        } else {
            drawerContentViewController[index] = controller
            setDrawerPosition(position: drawerPosition[index], animated: false, index: index)

            completion?(true)
        }
    }

    /**
     Change the current drawer content view controller (The one inside the drawer). This method exists for backwards compatibility.

     - parameter controller: The controller to replace it with
     - parameter animated:   Whether or not to animate the change.
     */
    public func setDrawerContentViewController(controller: UIViewController, animated: Bool = true, index: Int) {
        setDrawerContentViewController(controller: controller, animated: animated, completion: nil, index: index)
    }

    /**
     Update the supported drawer positions allows by the Pulley Drawer
     */
    public func setNeedsSupportedDrawerPositionsUpdate(index: Int) {
        let drawerVCCompliant = drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate
        supportedDrawerPositions = drawerVCCompliant.supportedDrawerPositions()
    }


    // MARK: Actions

    func dimmingViewTapRecognizerAction(gestureRecognizer: UITapGestureRecognizer) {
        var index = -1

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
        }
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
            return backgroundDimmingView[index]
        }

        return primaryContentContainer
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

        // Find the closest anchor point and snap there.
        var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight
        var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight

        let drawerVCCompliant = drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate
        collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
        partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()

        var drawerStops: [CGFloat] = [CGFloat]()

        if supportedDrawerPositions.contains(.open) {
            drawerStops.append((self.view.bounds.size.height - topInset))
        }

        if supportedDrawerPositions.contains(.partiallyRevealed) {
            drawerStops.append(partialRevealHeight)
        }

        if supportedDrawerPositions.contains(.collapsed) {
            drawerStops.append(collapsedHeight)
        }

        let lowestStop = drawerStops.min() ?? 0

        let distanceFromBottomOfView = lowestStop + lastDragTargetContentOffset[index].y

        var currentClosestStop = lowestStop

        for currentStop in drawerStops {
            if abs(currentStop - distanceFromBottomOfView) < abs(currentClosestStop - distanceFromBottomOfView) {
                currentClosestStop = currentStop
            }
        }

        if abs(Float(currentClosestStop - (self.view.bounds.size.height - topInset))) <= Float.ulpOfOne && supportedDrawerPositions.contains(.open) {
            setDrawerPosition(position: .open, animated: true, index: index)
        } else if abs(Float(currentClosestStop - collapsedHeight)) <= Float.ulpOfOne && supportedDrawerPositions.contains(.collapsed) {
            setDrawerPosition(position: .collapsed, animated: true, index: index)
        } else if supportedDrawerPositions.contains(.partiallyRevealed) {
            setDrawerPosition(position: .partiallyRevealed, animated: true, index: index)
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

        Log.debug("scrollViewDidScroll scroll index: \(index)")

        var partialRevealHeight: CGFloat = kPulleyDefaultPartialRevealHeight
        var collapsedHeight: CGFloat = kPulleyDefaultCollapsedHeight

        let drawerVCCompliant = drawerContentViewController[index] as! PulleyDrawerViewControllerDelegate
        collapsedHeight = drawerVCCompliant.collapsedDrawerHeight()
        partialRevealHeight = drawerVCCompliant.partialRevealDrawerHeight()

        var drawerStops: [CGFloat] = [CGFloat]()

        if supportedDrawerPositions.contains(.open) {
            drawerStops.append((self.view.bounds.size.height - topInset))
        }

        if supportedDrawerPositions.contains(.partiallyRevealed) {
            drawerStops.append(partialRevealHeight)
        }

        if supportedDrawerPositions.contains(.collapsed) {
            drawerStops.append(collapsedHeight)
        }

        let lowestStop = drawerStops.min() ?? 0

        if scrollView.contentOffset.y > partialRevealHeight - lowestStop {
            // Calculate percentage between partial and full reveal
            let fullRevealHeight = (self.view.bounds.size.height - topInset)

            let progress = (scrollView.contentOffset.y - (partialRevealHeight - lowestStop)) / (fullRevealHeight - (partialRevealHeight))

            delegate?.makeUIAdjustmentsForFullscreen?(progress: progress)
            (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress)
            (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: progress)

            backgroundDimmingView[index].alpha = progress * backgroundDimmingOpacity

            backgroundDimmingView[index].isUserInteractionEnabled = true
        } else {
            if backgroundDimmingView[index].alpha >= 0.001 {
                backgroundDimmingView[index].alpha = 0.0

                delegate?.makeUIAdjustmentsForFullscreen?(progress: 0.0)
                (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0)
                (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?.makeUIAdjustmentsForFullscreen?(progress: 0.0)

                backgroundDimmingView[index].isUserInteractionEnabled = false
            }
        }

        delegate?.drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop)

        (drawerContentViewController as? PulleyDrawerViewControllerDelegate)?
                .drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop)

        (primaryContentViewController as? PulleyPrimaryContentControllerDelegate)?
                .drawerChangedDistanceFromBottom?(drawer: self, distance: scrollView.contentOffset.y + lowestStop)
    }
}
