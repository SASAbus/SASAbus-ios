import UIKit

class IntroViewController: UIPageViewController {

    weak var introDelegate: IntroPageViewControllerDelegate?

    var dataOnly: Bool = false
    var dataUpdateFinished: Bool = false

    private(set) lazy var pageViewControllers = [IntroPageViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if !dataOnly {
            pageViewControllers.append(newViewController(
                    index: 0,
                    color: Color.red,
                    title: L10n.Intro.Realtime.title,
                    subtitle: L10n.Intro.Realtime.subtitle,
                    description: L10n.Intro.Realtime.description,
                    image: "intro_realtime"
            ))
        }

        pageViewControllers.append(newDataViewController(
                index: 1,
                color: Color.green,
                title: L10n.Intro.Data.title,
                subtitle: L10n.Intro.Data.subtitle,
                description: L10n.Intro.Data.description,
                image: "intro_data"
        ))

        if !dataOnly {
            pageViewControllers.append(newViewController(
                    index: 2,
                    color: Color.tealBlue,
                    title: L10n.Intro.Beacons.title,
                    subtitle: L10n.Intro.Beacons.subtitle,
                    description: L10n.Intro.Beacons.description,
                    image: "intro_bluetooth"
            ))

            pageViewControllers.append(newViewController(
                    index: 3,
                    color: Color.yellow,
                    title: L10n.Intro.Agreement.title,
                    subtitle: L10n.Intro.Agreement.subtitle,
                    description: L10n.Intro.Agreement.description,
                    image: "intro_agreement"
            ))

            pageViewControllers.append(newViewController(
                    index: 4,
                    color: Color.orange,
                    title: L10n.Intro.Permission.title,
                    subtitle: L10n.Intro.Permission.subtitle,
                    description: L10n.Intro.Permission.description,
                    image: "intro_permission"
            ))
        }

        delegate = self
        dataSource = self

        introDelegate?.introPageViewController(didUpdatePageCount: pageViewControllers.count)

        self.setViewControllers([self.pageViewControllers.first!], direction: .forward, animated: false)

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

        controller.showCloseButton = dataOnly

        return controller
    }


    func didFinishDataDownload() {
        dataUpdateFinished = true
        
        guard !dataOnly else {
            return
        }
        
        DispatchQueue.main.async {
            let index = 2
            let newController = self.pageViewControllers[index]
            
            self.setViewControllers([newController], direction: .forward, animated: true)
            self.introDelegate?.introPageViewController(didUpdatePageIndex: index, color: newController.color)
        }
    }
}

extension IntroViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let viewController = viewControllers?.first as! IntroPageViewController

        if let index = pageViewControllers.index(of: viewController) {
            introDelegate?.introPageViewController(didUpdatePageIndex: index, color: viewController.color)
        }
    }
}

extension IntroViewController: UIPageViewControllerDataSource {

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
        let count = pageViewControllers.count
        
        if viewControllerIndex == 1 && !dataUpdateFinished {
            return nil
        }

        guard count != nextIndex else {
            return nil
        }

        guard count > nextIndex else {
            return nil
        }

        return pageViewControllers[nextIndex]
    }
}


protocol IntroPageViewControllerDelegate: class {
    
    func introPageViewController(didUpdatePageCount count: Int)
    func introPageViewController(didUpdatePageIndex index: Int, color: UIColor)
}
