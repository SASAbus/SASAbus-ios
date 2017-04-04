import UIKit

class IntroViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    weak var introDelegate: IntroPageViewControllerDelegate?

    var dataOnly: Bool = false

    private(set) lazy var pageViewControllers = [IntroPageViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if !dataOnly {
            pageViewControllers.append(newViewController(
                index: 0,
                color: Color.red,
                title: "Real-time",
                subtitle: "Bus positions in real-time",
                description: "SasaBus informs you about bus positions, departures and delays in real-time",
                image: "intro_realtime"
            ))
        }

        pageViewControllers.append(newDataViewController(
            index: 1,
            color: Color.green,
            title: "Offline data",
            subtitle: "All data saved offline",
            description: "The app downloads all bus departures and stores them locally, so you can access them anytime",
            image: "intro_data"
        ))

        if !dataOnly {
            pageViewControllers.append(newViewController(
                index: 2,
                color: Color.tealBlue,
                title: "Beacon",
                subtitle: "Get information about the bus you're in",
                description: "Enable bluetooth to get information of nearby buses and bus stops.",
                image: "intro_bluetooth"
            ))

            pageViewControllers.append(newViewController(
                index: 3,
                color: Color.yellow,
                title: "Agreement",
                subtitle: "Terms and conditions",
                description: "By using SasaBus you agree to the Terms and Conditions and the Privacy Policy.",
                image: "intro_agreement"
            ))

            pageViewControllers.append(newViewController(
                index: 4,
                color: Color.orange,
                title: "Permission",
                subtitle: "Beacon tracking needs your location",
                description: "Please allow the app to use your location to scan for beacons",
                image: "intro_permission"
            ))
        }

        delegate = self
        dataSource = self

        introDelegate?.introPageViewController(didUpdatePageCount: pageViewControllers.count)

        if let firstViewController = pageViewControllers.first {
            DispatchQueue.main.async {
                self.setViewControllers([firstViewController],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
            }
        }

        view.backgroundColor = UIColor.white
    }

    private func newViewController(index: Int, color: UIColor, title: String, subtitle: String,
                                   description: String, image: String) -> IntroPageViewController {

        let controller = UIStoryboard(name: "Intro", bundle: nil)
            .instantiateViewController(withIdentifier: "intro_page") as! IntroPageViewController

        controller.index = index
        controller.color = color
        controller.titleString = title
        controller.subtitleString = subtitle
        controller.descriptionString = description
        controller.imageString = image

        return controller
    }

    private func newDataViewController(index: Int, color: UIColor, title: String, subtitle: String,
                                       description: String, image: String) -> IntroDataPageViewController {

        let controller = UIStoryboard(name: "Intro", bundle: nil)
            .instantiateViewController(withIdentifier: "intro_page_data") as! IntroDataPageViewController

        controller.parentVC = self
        controller.index = index
        controller.color = color
        controller.titleString = title
        controller.subtitleString = subtitle
        controller.descriptionString = description
        controller.imageString = image

        return controller
    }

    func setSwipeable(swipeable: Bool) {
        for view in self.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = swipeable
            }
        }
    }


    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let viewController = viewControllers?.first as! IntroPageViewController

        if let index = pageViewControllers.index(of: viewController) {
            introDelegate?.introPageViewController(didUpdatePageIndex: index, color: viewController.color)
        }
    }


    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageViewControllers.index(of: viewController as! IntroPageViewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard pageViewControllers.count > previousIndex else {
            return nil
        }

        return pageViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageViewControllers.index(of: viewController as! IntroPageViewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = pageViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return pageViewControllers[nextIndex]
    }
}

protocol IntroPageViewControllerDelegate: class {
    func introPageViewController(didUpdatePageCount count: Int)
    func introPageViewController(didUpdatePageIndex index: Int, color: UIColor)
}
