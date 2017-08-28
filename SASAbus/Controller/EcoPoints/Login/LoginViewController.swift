import UIKit

import RxSwift
import RxCocoa

import GoogleSignIn

import Crashlytics


class LoginViewController: UIViewController {

    @IBOutlet weak var background: UIView!

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var googleButton: GIDSignInButton!

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var bar: UINavigationBar!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var googleActivityIndicator: UIActivityIndicatorView!

    var hairLineImage: UIImageView!

    var parentVC: EcoPointsViewController!

    public static let googleLoginSuccess = Notification.Name("GoogleSignInSuccess")
    public static let googleLoginError = Notification.Name("GoogleSignInError")


    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        background.backgroundColor = Color.loginBackground

        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true

        activityIndicator.alpha = 0

        GIDSignIn.sharedInstance().uiDelegate = self
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
                    self.loginSuccess(email: emailString, token: token, isGoogleSignIn: false)
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

    func animateGoogleViews(_ showButton: Bool, duration: TimeInterval = 0.25) {
        if showButton {
            googleActivityIndicator.stopAnimating()

            UIView.animate(withDuration: duration) {
                self.googleButton.alpha = 1
                self.googleActivityIndicator.alpha = 0
            }
        } else {
            googleActivityIndicator.startAnimating()

            UIView.animate(withDuration: duration) {
                self.googleButton.alpha = 0
                self.googleActivityIndicator.alpha = 1
            }
        }
    }


    func loginSuccess(email: String?, token: String, isGoogleSignIn: Bool) {
        if AuthHelper.setInitialToken(token: token) {
            AuthHelper.setIsGoogleAccount(value: isGoogleSignIn)

            parentVC.loginComplete(completion: { _ in
                self.animateViews(true, duration: 0)
                self.animateGoogleViews(true, duration: 0)
                
                return nil
            })
            
            #if !DEBUG
                if let email = email {
                    Crashlytics.sharedInstance().setUserEmail(email)
                }
            #endif
        } else {
            Log.error("Could not set token")
            loginFailed()
        }
    }

    func loginFailed() {
        animateViews(true)
        animateGoogleViews(true)

        let alert = UIAlertController(title: L10n.Ecopoints.Login.Error.title,
                message: L10n.Ecopoints.Login.Error.subtitle, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}

extension LoginViewController: GIDSignInUIDelegate {

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print("signInWillDispatch")

        button.isUserInteractionEnabled = false

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(googleSignInSuccess(withNotification:)),
                name: LoginViewController.googleLoginSuccess,
                object: nil
        )

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(googleSignInError(withNotification:)),
                name: LoginViewController.googleLoginError,
                object: nil
        )
    }

    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("signInWillPresent")

        self.present(viewController, animated: true, completion: nil)
    }

    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        print("signInWillDismiss")

        self.dismiss(animated: true, completion: nil)

        button.isUserInteractionEnabled = false

        animateGoogleViews(false)
    }


    func googleSignInSuccess(withNotification notification: NSNotification) {
        Log.warning("Got google sign in success")

        NotificationCenter.default.removeObserver(self, name: LoginViewController.googleLoginSuccess, object: nil);
        NotificationCenter.default.removeObserver(self, name: LoginViewController.googleLoginError, object: nil);

        Log.warning("Starting google login...")

        guard let userInfo = notification.userInfo, let userId = userInfo["user_id"] as? String else {
            Log.error("ID token missing in notification")
            self.loginFailed()
            return
        }

        _ = UserApi.loginGoogle(userId: userId)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { json in
                    Log.info("Google login response: \(json)")

                    guard let token = json["access_token"].string else {
                        Log.error("Token is nil")
                        self.loginFailed()
                        return
                    }

                    Log.warning("Google login success, got token: \(token)")
                    self.loginSuccess(email: userInfo["email"] as? String, token: token, isGoogleSignIn: false)
                }, onError: { error in
                    Log.error("Error: \(error)")

                    self.loginFailed()
                })
    }

    func googleSignInError(withNotification notification: NSNotification) {
        Log.warning("Got google sign in error")

        self.loginFailed()

        NotificationCenter.default.removeObserver(self, name: LoginViewController.googleLoginSuccess, object: nil);
        NotificationCenter.default.removeObserver(self, name: LoginViewController.googleLoginError, object: nil);
    }
}
