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

        pointsImage.tint(with: Theme.blue)
        rankImage.tint(with: Theme.blue)
        badgesImage.tint(with: Theme.blue)
    }

    @IBAction func settingsButtonClick(_ sender: UIButton) {
        if let click = self.onButtonTapped {
            click()
        }
    }
}
