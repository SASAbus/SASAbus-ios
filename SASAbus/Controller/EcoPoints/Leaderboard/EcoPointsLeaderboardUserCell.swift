import UIKit

class EcoPointsLeaderboardUserCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var rankText: UILabel!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var pointsText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 24 // 48 / 2
        profileImage.layer.masksToBounds = true
        profileImage.clipsToBounds = true
    }
}
