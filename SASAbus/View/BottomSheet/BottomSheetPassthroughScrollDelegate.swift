import UIKit

protocol BottomSheetPassthroughScrollViewDelegate: class {
    func shouldTouchPassthroughScrollView(scrollView: BottomSheetPassthroughScrollView, point: CGPoint) -> Bool
    func viewToReceiveTouch(scrollView: BottomSheetPassthroughScrollView) -> UIView
}

public class BottomSheetPassthroughScrollView: UIScrollView {

    weak var touchDelegate: BottomSheetPassthroughScrollViewDelegate?

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let touchDel = touchDelegate {
            if touchDel.shouldTouchPassthroughScrollView(scrollView: self, point: point) {
                return touchDel.viewToReceiveTouch(scrollView: self).hitTest(touchDel.viewToReceiveTouch(scrollView: self)
                    .convert(point, from: self), with: event)
            }
        }

        return super.hitTest(point, with: event)
    }
}
