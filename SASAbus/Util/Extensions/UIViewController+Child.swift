import Foundation
import UIKit

extension UIViewController {

    func addChildController(_ viewController: UIViewController?, container: UIView) {
        guard let controller = viewController else {
            Log.error("No view controller provided")
            return
        }

        let view = controller.view
        view!.translatesAutoresizingMaskIntoConstraints = true

        container.addSubview(view!)
        self.addChildViewController(controller)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }
    }
}