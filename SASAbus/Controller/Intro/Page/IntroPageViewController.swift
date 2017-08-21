import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()

        if let button = button {
            if index != 4 {
                button.isHidden = true
            }

            button.backgroundColor = color

            let click = UITapGestureRecognizer(target: self, action: #selector(finishIntro))
            click.numberOfTapsRequired = 1

            button.isUserInteractionEnabled = true
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
        Settings.setIntroFinished()
        (UIApplication.shared.delegate as! AppDelegate).startApplication()
    }
}
