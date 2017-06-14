import Foundation
import UIKit
import SwiftValidator

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

extension UITextField {

    private static let association = ObjectAssociation<UIView>()

    var outerView: UIView? {
        get {
            return UITextField.association[self]
        }
        set {
            UITextField.association[self] = newValue
        }
    }
}

extension UITextView: Validatable {

    public var validationText: String {
        return text ?? ""
    }
}

public final class ObjectAssociation<T:AnyObject> {

    private let policy: objc_AssociationPolicy

    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.policy = policy
    }

    public subscript(index: AnyObject) -> T? {
        get {
            return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T?
        }
        set {
            objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy)
        }
    }
}
