//
// Created by Alex Lardschneider on 29/03/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

fileprivate var activityIndicatorViewAssociativeKey = "ActivityIndicatorViewAssociativeKey"

public extension UITableView {

    var activityIndicatorView: UIActivityIndicatorView {
        get {
            if let activityIndicatorView = objc_getAssociatedObject(self, &activityIndicatorViewAssociativeKey) as? UIActivityIndicatorView {
                return activityIndicatorView
            } else {
                let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.color = .gray

                addSubview(activityIndicatorView)

                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

                objc_setAssociatedObject(self, &activityIndicatorViewAssociativeKey,
                        activityIndicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

                return activityIndicatorView
            }
        }

        set {
            addSubview(newValue)
            objc_setAssociatedObject(self, &activityIndicatorViewAssociativeKey,
                    activityIndicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
