import Foundation
import UIKit

class UIUtils {

    static func tintImage(image: UIImageView, tint: UIColor) {
        image.image = image.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        image.tintColor = tint
    }
}
