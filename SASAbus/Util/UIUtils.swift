import Foundation
import UIKit

class UIUtils {

    static func getColorForDelay(delay: Int) -> UIColor {
        if delay > 3 {
            return Color.materialRed500
        } else if delay > 0 {
            return Color.materialAmber500
        } else {
            return Color.materialGreen500
        }
    }
}

extension UIImageView {

    func tint(with: UIColor) {
        image = image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        tintColor = with
    }
}
