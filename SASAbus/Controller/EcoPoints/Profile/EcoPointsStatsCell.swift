import UIKit

class EcoPointsStatsCell: UITableViewCell {

    @IBOutlet weak var distanceImage: UIImageView!
    @IBOutlet weak var distanceText: UILabel!

    @IBOutlet weak var totalTripsText: UILabel!
    @IBOutlet weak var totalTripsImage: UIImageView!

    @IBOutlet weak var co2Text: UILabel!
    @IBOutlet weak var co2Image: UIImageView!

    @IBOutlet weak var moneyText: UILabel!
    @IBOutlet weak var moneyImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        distanceImage.tint(with: Theme.blue)
        totalTripsImage.tint(with: Theme.blue)
        moneyImage.tint(with: Theme.blue)
        co2Image.tint(with: Theme.blue)
    }
}
