import Foundation
import UIKit
import StatefulViewController
import ChameleonFramework

class EmptyStateBaseView: UIView, StatefulPlaceholderView {

    let nib: String
    let imageTint: UIColor

    init(frame: CGRect, nib: String, imageTint: UIColor = Theme.orange.lighten(byPercentage: 0.75)!) {
        self.nib = nib
        self.imageTint = imageTint

        super.init(frame: frame)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    func setupView() {
        let centerView = Bundle.main.loadNibNamed(nib, owner: nil, options: nil)![0] as! EmptyStateView

        centerView.image.tint(with: imageTint)
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
        return UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
    }
}