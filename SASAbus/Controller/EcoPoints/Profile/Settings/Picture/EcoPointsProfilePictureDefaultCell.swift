import Foundation
import UIKit

class EcoPointsProfilePictureDefaultCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.25, animations: {
                    self.image.alpha = 0.7
                }, completion: { _ in
                    UIView.animate(withDuration: 0.25) {
                        self.image.alpha = 1
                    }
                })
            }
        }
    }
}
