import UIKit

class EcoPointsTabViewController: UITabBarController {

    var profileViewController: EcoPointsProfileViewController!
    var leaderboardViewController: EcoPointsLeaderboardViewController!
    var badgesViewController: EcoPointsBadgesViewController!

    var parentVC: EcoPointsViewController!

    var currentTab: Int = 0


    override func viewDidLoad() {
        super.viewDidLoad()

        profileViewController = EcoPointsProfileViewController()
        leaderboardViewController = EcoPointsLeaderboardViewController()
        badgesViewController = EcoPointsBadgesViewController()

        profileViewController.tabBarItem = UITabBarItem(
            title: L10n.Ecopoints.TabBar.profile,
            image: Asset.icAccountCircleWhite36pt.image,
            tag: 0
        )

        leaderboardViewController.tabBarItem = UITabBarItem(
            title: L10n.Ecopoints.TabBar.leaderboard,
            image: Asset.icListWhite36pt.image,
            tag: 1
        )

        badgesViewController.tabBarItem = UITabBarItem(
            title: L10n.Ecopoints.TabBar.badges,
            image: Asset.icLoyaltyWhite36pt.image,
            tag: 2
        )

        self.viewControllers = [profileViewController, leaderboardViewController, badgesViewController]

        self.tabBar.tintColor = Theme.orange
        self.tabBar.isTranslucent = false
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        currentTab = item.tag

        if item.tag == 0 {
            showButton()
        } else {
            parentVC.navigationItem.rightBarButtonItem = nil
        }
    }


    public func showButton() {
        if currentTab != 0 {
            return
        }

        let image = Asset.icSettingsWhite.image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)

        let button = UIBarButtonItem(
                image: image,
                style: .plain,
                target: profileViewController,
                action: #selector(EcoPointsProfileViewController.openSettings)
        )

        parentVC.navigationItem.rightBarButtonItem = button
    }
}
