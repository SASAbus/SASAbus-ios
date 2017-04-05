import Foundation
import UIKit

class UIUtils {

    static func tintImage(image: UIImageView, tint: UIColor) {
        image.image = image.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        image.tintColor = tint
    }

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
