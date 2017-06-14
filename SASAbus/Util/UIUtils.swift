import Foundation
import UIKit

extension UIImageView {

    func tint(with: UIColor) {
        image = image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        tintColor = with
    }
}

extension UIViewController {

    func showCloseDialog(title: String, message: String, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))

        self.present(alert, animated: true, completion: nil)
    }
}
