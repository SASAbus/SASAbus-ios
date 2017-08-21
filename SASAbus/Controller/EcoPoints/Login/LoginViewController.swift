import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var button: UIButton!

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var bar: UINavigationBar!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var hairLineImage: UIImageView!

    var parentVC: EcoPointsViewController!


    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        background.backgroundColor = Color.loginBackground

        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true

        activityIndicator.alpha = 0
    }


    @IBAction func validateForm(_ sender: AnyObject) {
        login()
    }


    func login() {
        Log.warning("Starting login...")

        guard let emailString = email.text else {
            Log.error("No email provided")
            return
        }

        guard let passwordString = password.text else {
            Log.error("No password provided")
            return
        }

        animateViews(false)

        _ = UserApi.login(email: emailString, password: passwordString)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { json in
                    Log.info("Login response: \(json)")

                    guard json["success"].boolValue else {
                        Log.error("Login failure, got error: \(json["error"].stringValue)")
                        self.loginFailed()
                        return
                    }

                    guard let token = json["access_token"].string else {
                        Log.error("Token is nil")
                        self.loginFailed()
                        return
                    }

                    Log.warning("Login success, got token: \(token)")
                    self.loginSuccess(token: token, isGoogleSignIn: false)
                }, onError: { error in
                    Log.error("Error: \(error)")

                    self.loginFailed()
                })

    }

    func animateViews(_ showButton: Bool, duration: TimeInterval = 0.25) {
        if showButton {
            activityIndicator.stopAnimating()

            UIView.animate(withDuration: duration) {
                self.button.alpha = 1
                self.activityIndicator.alpha = 0
            }
        } else {
            activityIndicator.startAnimating()

            UIView.animate(withDuration: duration) {
                self.button.alpha = 0
                self.activityIndicator.alpha = 1
            }
        }
    }


    func loginSuccess(token: String, isGoogleSignIn: Bool) {
        if AuthHelper.setInitialToken(token: token) {
            AuthHelper.setIsGoogleAccount(value: isGoogleSignIn)

            parentVC.loginComplete(completion: { _ in
                self.animateViews(true, duration: 0)
            })
        } else {
            Log.error("Could not set token")
            loginFailed()
        }
    }

    func loginFailed() {
        animateViews(true)

        let alert = UIAlertController(title: "Could not log in",
                message: "Please retry in a few minutes", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}
