import UIKit

class EcoPointsViewController: MasterViewController {

    @IBOutlet var loginContainer: UIView!
    @IBOutlet var contentContainer: UIView!

    var ecoPointsController: EcoPointsTabViewController!

    var isLoginActive: Bool = false


    init() {
        super.init(nibName: "EcoPointsViewController", title: "Eco Points")
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        let loginNib = UINib(nibName: "LoginViewController", bundle: nil)
        let loginViewController = loginNib.instantiate(withOwner: self)[0] as! LoginViewController
        loginViewController.parentVC = self

        let ecoPointsNib = UINib(nibName: "EcoPointsTabViewController", bundle: nil)
        ecoPointsController = ecoPointsNib.instantiate(withOwner: self)[0] as! EcoPointsTabViewController
        ecoPointsController.parentVC = self

        addChildController(loginViewController, container: loginContainer)
        addChildController(ecoPointsController, container: contentContainer)

        if !AuthHelper.isLoggedIn() {
            isLoginActive = true

            Log.warning("User is not logged in")

            loginContainer.isHidden = false
            contentContainer.isHidden = true
        } else {
            loginContainer.isHidden = true
            contentContainer.isHidden = false

            ecoPointsController.showButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.rightBarButtonItem = nil

        if !AuthHelper.isLoggedIn() {
            isLoginActive = true

            Log.warning("User is not logged in")

            loginContainer.isHidden = false
            loginContainer.alpha = 1

            contentContainer.isHidden = true
        } else {
            ecoPointsController.showButton()
        }

        if isLoginActive, let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.loginBackground
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isLoginActive, let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Theme.orange
        }
    }


    func loginComplete(completion: @escaping () -> Void?) {
        isLoginActive = false

        UIView.animate(withDuration: 0.25, animations: {
            self.loginContainer.alpha = 0
            self.contentContainer.alpha = 1

            if let navController = self.navigationController {
                navController.navigationBar.tintColor = UIColor.white
                navController.navigationBar.barTintColor = Theme.orange
            }

            // Cannot load profile earlier because auth token is not set
            self.ecoPointsController.profileViewController.parseProfile()
        }, completion: { _ in
            self.loginContainer.isHidden = true
            self.contentContainer.isHidden = false

            self.ecoPointsController.showButton()

            completion()
        })
    }
}
