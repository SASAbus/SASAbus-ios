import Foundation
import UIKit

extension UIViewController {

    func addChildController(_ viewController: UIViewController?, container: UIView) {
        guard let controller = viewController else {
            Log.error("No view controller provided")
            return
        }

        let view = controller.view
        let containerSize = container.frame.size

        view!.translatesAutoresizingMaskIntoConstraints = true
        view!.frame = CGRect(x: 0, y: 0, width: containerSize.width, height: containerSize.height)

        container.addSubview(view!)
        self.addChildViewController(controller)

        if self.isViewLoaded {
            self.view.setNeedsLayout()
        }
    }
}
