import UIKit

class EcoPointsProfileCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!

    @IBOutlet weak var pointsImage: UIImageView!
    @IBOutlet weak var rankImage: UIImageView!
    @IBOutlet weak var badgesImage: UIImageView!

    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var levelText: UILabel!

    @IBOutlet weak var pointsText: UILabel!
    @IBOutlet weak var rankText: UILabel!
    @IBOutlet weak var badgesText: UILabel!

    @IBOutlet weak var loadingView: UIView!

    @IBOutlet weak var settingsButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var onButtonTapped : (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        activityIndicator.startAnimating()

        profilePicture.layer.cornerRadius = 56 // 112 / 2
        profilePicture.layer.masksToBounds = true
        profilePicture.clipsToBounds = true

        UIUtils.tintImage(image: pointsImage, tint: Color.materialIndigo500)
        UIUtils.tintImage(image: rankImage, tint: Color.materialIndigo500)
        UIUtils.tintImage(image: badgesImage, tint: Color.materialIndigo500)
    }

    @IBAction func settingsButtonClick(_ sender: UIButton) {
        print(sender.tag)

        if let onButtonTapped = self.onButtonTapped {
            onButtonTapped()
        }
    }
}
