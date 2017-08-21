import Foundation

import UIKit
import StatefulViewController

class LoadingView: BasicPlaceholderView {

    let label = UILabel()

    override func setupView() {
        super.setupView()

        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = .gray
        activityIndicatorView.startAnimating()

        addSubview(activityIndicatorView)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
