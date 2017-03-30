import UIKit

class EcoPointsTabViewController: UITabBarController {

    var parentVC: EcoPointsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileViewController = EcoPointsProfileViewController()
        let leaderboardViewController = EcoPointsLeaderboardViewController()
        let badgesViewController = EcoPointsBadgesViewController()

        profileViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: ""),
                image: UIImage(named: "ic_account_circle_white_36pt"), selectedImage: nil)

        leaderboardViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Leaderboard", comment: ""),
                image: UIImage(named: "ic_list_white_36pt"), selectedImage: nil)

        badgesViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Badges", comment: ""),
                image: UIImage(named: "ic_loyalty_white_36pt"), selectedImage: nil)

        self.viewControllers = [profileViewController, leaderboardViewController, badgesViewController]
        self.tabBar.tintColor = Theme.orange
        self.tabBar.isTranslucent = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
