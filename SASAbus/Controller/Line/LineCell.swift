import Foundation
import UIKit

class LineCell: UITableViewCell {

    @IBOutlet weak var titleLeft: UILabel!
    @IBOutlet weak var titleRight: UILabel!

    @IBOutlet weak var subtitleTop: UILabel!
    @IBOutlet weak var subtitleBottom: UILabel!

    @IBOutlet weak var imageTop: UIImageView!
    @IBOutlet weak var imageBottom: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageTop.tint(with: Color.iconDark)
        imageBottom.tint(with: Color.iconDark)
    }
}
