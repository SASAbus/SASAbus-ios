import UIKit

class EcoPointsTabViewController: UITabBarController {

    var profileViewController: EcoPointsProfileViewController!
    var leaderboardViewController: EcoPointsLeaderboardViewController!
    var badgesViewController: EcoPointsBadgesViewController!

    var parentVC: EcoPointsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        profileViewController = EcoPointsProfileViewController()
        leaderboardViewController = EcoPointsLeaderboardViewController()
        badgesViewController = EcoPointsBadgesViewController()

        profileViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: ""),
                image: UIImage(named: "ic_account_circle_white_36pt"), tag: 0)

        leaderboardViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Leaderboard", comment: ""),
                image: UIImage(named: "ic_list_white_36pt"), tag: 1)

        badgesViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Badges", comment: ""),
                image: UIImage(named: "ic_loyalty_white_36pt"), tag: 2)

        self.viewControllers = [profileViewController, leaderboardViewController, badgesViewController]

        self.tabBar.tintColor = Theme.orange
        self.tabBar.isTranslucent = false

        showButton()
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item.tag)

        if item.tag == 0 {
            showButton()
        } else {
            parentVC.navigationItem.rightBarButtonItem = nil
        }
    }

    func showButton() {
        let image = UIImage(named: "ic_settings_white")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

        var button = UIBarButtonItem(
                image: image,
                style: .plain,
                target: profileViewController,
                action: #selector(EcoPointsProfileViewController.openSettings)
        )

        //button = UIBarButtonItem(barButtonSystemItem: .cancel,
        //        target: self, action: #selector(profileViewController.openSettings))

        parentVC.navigationItem.rightBarButtonItem = button
    }
}
