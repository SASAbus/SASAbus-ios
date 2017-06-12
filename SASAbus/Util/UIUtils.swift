import Foundation
import UIKit

extension UIImageView {

    func tint(with: UIColor) {
        image = image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        tintColor = with
    }
}