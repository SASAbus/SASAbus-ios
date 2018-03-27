import UIKit
import CoreLocation
import Permission

class IntroPageViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!

    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var subtitleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var button: UIButton!

    var index: Int!
    var color: UIColor!
    var titleString: String!
    var subtitleString: String!
    var descriptionString: String!
    var imageString: String!
    
    var dataOnly: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let button = button {
            if index != 4 {
                button.isHidden = true
            }

            button.backgroundColor = color

            let click = UITapGestureRecognizer(target: self, action: #selector(finishIntro))
            button.addGestureRecognizer(click)
        }

        titleText.text = titleString
        subtitleText.text = subtitleString
        descriptionText.text = descriptionString
        image.image = UIImage(named: imageString)

        titleText.textColor = color
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let button = button {
            button.layer.cornerRadius = button.frame.size.height / 2
            button.layer.masksToBounds = true
        }
    }

    
    func finishIntro() {
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        
        if dataOnly {
            delegate.startApplication()
            return
        }
        
        let notification: Permission = .notifications
        let location: Permission = .locationAlways
        
        notification.request { status in
            if status == .authorized {
                Log.info("Notification permission authorized")
            } else {
                Log.warning("Notification permission denied: \(status.description)")
                NotificationSettings.disableAllNotifications()
            }
            
            location.request { status in
                if status == .authorized {
                    Log.info("Location permission authorized")
                } else {
                    Log.warning("Location permission denied: \(status.description)")
                    Settings.setBeaconsEnabled(false)
                }
                
                Settings.setIntroFinished()
                
                delegate.startApplication()
                delegate.setupBeacons()
            }
        }
    }
}
