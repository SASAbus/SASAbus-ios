import Foundation
import UIKit
import StatefulViewController

class BasicPlaceholderView: UIView, StatefulPlaceholderView {

    let centerView: UIView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
    }

    func setupView() {
        centerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(centerView)

        let views = ["centerView": centerView, "superview": self]

        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[superview]-(<=1)-[centerView]",
                options: .alignAllCenterX,
                metrics: nil,
                views: views)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(<=1)-[centerView]",
                options: .alignAllCenterY,
                metrics: nil,
                views: views)

        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
    }

    func placeholderViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: 64, left: 0, bottom: 64, right: 0)
    }
}
