import UIKit

class EcoPointsViewController: MasterViewController {

    @IBOutlet var loginContainer: UIView!
    @IBOutlet var contentContainer: UIView!

    var hairLineImage: UIImageView!
    var isLoginActive: Bool = false


    init(title: String?) {
        super.init(nibName: "EcoPointsViewController", title: title)
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

            loginContainer.alpha = 1
            contentContainer.alpha = 0

            /*for parent in self.navigationController.navigationBar.subviews {
                for childView in parent.subviews {
                    if childView is UIImageView && childView.bounds.height <= 1 {
                        hairLineImage = childView as! UIImageView
                    }
                }
            }*/
        } else {
            loginContainer.alpha = 0
            contentContainer.alpha = 1
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isLoginActive, let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.loginBackground

            // hairLineImage.alpha = 0
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isLoginActive, let navController = self.navigationController {
            navController.navigationBar.tintColor = UIColor.white
            navController.navigationBar.barTintColor = Color.materialOrange500

            // hairLineImage.alpha = 1
        }
    }


    func loginComplete() {
        isLoginActive = false

        UIView.animate(withDuration: 0.2) {
            self.loginContainer.alpha = 0
            self.contentContainer.alpha = 1

            if let navController = self.navigationController {
                navController.navigationBar.tintColor = UIColor.white
                navController.navigationBar.barTintColor = Color.materialOrange500

                self.hairLineImage.alpha = 1
            }
        }
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
