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
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                Log.info("Login response: \(json)")

                if json["success"].boolValue {
                    if let token = json["access_token"].string {
                        Log.warning("Login success, got token: \(token)")
                        self.loginSuccess(token: token, isGoogleSignIn: false)
                    } else {
                        Log.error("Token is nil")
                        self.loginFailed(error: "token_not_found")
                    }

                    return
                }

                Log.error("Login failure, got error: \(json["error"].stringValue)")
            }, onError: { error in
                Log.error("Error: \(error)")

                self.loginFailed(error: error.localizedDescription)
            })

    }

    func animateViews(_ showButton: Bool) {
        if showButton {
            activityIndicator.stopAnimating()

            UIView.animate(withDuration: 0.25) {
                self.button.alpha = 1
                self.activityIndicator.alpha = 0
            }
        } else {
            activityIndicator.startAnimating()

            UIView.animate(withDuration: 0.25) {
                self.button.alpha = 0
                self.activityIndicator.alpha = 1
            }
        }
    }


    func loginSuccess(token: String, isGoogleSignIn: Bool) {
        if AuthHelper.setInitialToken(token: token) {
            AuthHelper.setIsGoogleAccount(value: isGoogleSignIn)

            parentVC.loginComplete()
        } else {
            Log.error("Could not set token")
            loginFailed(error: "token_invalid")
        }
    }

    func loginFailed(error: String) {
        animateViews(true)
    }
}
