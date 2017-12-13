import Foundation

extension UIImage {

    func withInsets(insetDimen: CGFloat) -> UIImage {
        return withInsets(insets: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }

    func withInsets(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
                CGSize(
                    width: self.size.width + insets.left + insets.right,
                    height: self.size.height + insets.top + insets.bottom
                ), false, self.scale
        )

        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return imageWithInsets!
    }
}
