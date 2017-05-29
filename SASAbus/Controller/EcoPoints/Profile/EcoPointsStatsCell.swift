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

        distanceImage.tint(with: Color.materialIndigo500)
        totalTripsImage.tint(with: Color.materialIndigo500)
        moneyImage.tint(with: Color.materialIndigo500)
        co2Image.tint(with: Color.materialIndigo500)
    }
}
