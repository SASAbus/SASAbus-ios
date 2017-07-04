import UIKit

protocol PulleyPassthroughScrollViewDelegate: class {

    func shouldTouchPassthroughScrollView(scrollView: PulleyPassthroughScrollView, point: CGPoint) -> Bool

    func viewToReceiveTouch(scrollView: PulleyPassthroughScrollView) -> UIView
}

class PulleyPassthroughScrollView: UIScrollView {

    weak var touchDelegate: PulleyPassthroughScrollViewDelegate?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let delegate = touchDelegate {
            if delegate.shouldTouchPassthroughScrollView(scrollView: self, point: point) {
                let touchView = delegate.viewToReceiveTouch(scrollView: self)

                Log.error(touchView.isUserInteractionEnabled)

                return touchView.hitTest(touchView.convert(point, from: self), with: event)
            }
        }

        return super.hitTest(point, with: event)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let touchDel = touchDelegate {
            if touchDel.shouldTouchPassthroughScrollView(scrollView: self, point: point) {
                print("Passing all touches to the next view (if any), in the view stack.")
                return false
            }
        }

        return super.point(inside: point, with: event)
    }
}
