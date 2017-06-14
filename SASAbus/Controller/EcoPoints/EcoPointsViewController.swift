import UIKit

class EcoPointsViewController: MasterViewController {

    @IBOutlet var loginContainer: UIView!
    @IBOutlet var contentContainer: UIView!

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
        let ecoPointsController = ecoPointsNib.instantiate(withOwner: self)[0] as! EcoPointsTabViewController
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
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !AuthHelper.isLoggedIn() {
            isLoginActive = true

            Log.warning("User is not logged in")

            loginContainer.isHidden = false
            loginContainer.alpha = 1

            contentContainer.isHidden = true
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
            navController.navigationBar.barTintColor = Color.materialOrange500
        }
    }


    func loginComplete(completion: @escaping () -> Void?) {
        isLoginActive = false

        UIView.animate(withDuration: 0.25, animations: {
            self.loginContainer.alpha = 0
            self.contentContainer.alpha = 1

            if let navController = self.navigationController {
                navController.navigationBar.tintColor = UIColor.white
                navController.navigationBar.barTintColor = Color.materialOrange500
            }
        }, completion: { _ in
            self.loginContainer.isHidden = true
            self.contentContainer.isHidden = false

            completion()
        })
    }


    func addChildController(_ viewController: UIViewController?, container: UIView) {
        guard let controller = viewController else {
            return
        }

        let view = controller.view
        view!.translatesAutoresizingMaskIntoConstraints = true

        container.addSubview(view!)
        self.addChildViewController(controller)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }
    }
}
