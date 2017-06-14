import UIKit

class EcoPointsProfileSettingsCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!

    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var levelText: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        profilePicture.layer.cornerRadius = 56 // 112 / 2
        profilePicture.layer.masksToBounds = true
        profilePicture.clipsToBounds = true
    }
}
