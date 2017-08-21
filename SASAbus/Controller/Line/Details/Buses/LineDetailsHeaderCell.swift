import UIKit

class LineDetailsHeaderCell: UITableViewCell {

    @IBOutlet weak var originImage: UIImageView!
    @IBOutlet weak var originText: UILabel!

    @IBOutlet weak var destinationImage: UIImageView!
    @IBOutlet weak var destinationText: UILabel!

    @IBOutlet weak var cityImage: UIImageView!
    @IBOutlet weak var cityText: UILabel!

    @IBOutlet weak var timesImage: UIImageView!
    @IBOutlet weak var timesText: UILabel!

    @IBOutlet weak var infoText: UILabel!

    override func awakeFromNib() {
        originImage.tint(with: Color.iconDark)
        destinationImage.tint(with: Color.iconDark)
        cityImage.tint(with: Color.iconDark)
        timesImage.tint(with: Color.iconDark)
    }
}
