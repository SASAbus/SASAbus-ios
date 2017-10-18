import UIKit

class IntroParentViewController: UIViewController, IntroPageViewControllerDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    
    var dataOnly: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPageIndicatorTintColor = Color.red
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0

        if dataOnly {
            pageControl.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? IntroViewController {
            viewController.introDelegate = self
            viewController.dataOnly = dataOnly
        }
    }
    
    
    // MARK: - IntroPageViewControllerDelegate
    
    func introPageViewController(didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func introPageViewController(didUpdatePageIndex index: Int, color: UIColor) {
        pageControl.currentPage = index
        pageControl.currentPageIndicatorTintColor = color
    }
}
