//
// Created by Alex Lardschneider on 29/03/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

import UIKit

class ErrorView: BasicPlaceholderView {

    let textLabel = UILabel()
    let detailTextLabel = UILabel()

    var target: Any
    var action: Selector

    init(frame: CGRect, target: Any, action: Selector) {
        self.target = target
        self.action = action

        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    override func setupView() {
        super.setupView()

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(target, action: action)

        self.addGestureRecognizer(tapGestureRecognizer)

        textLabel.text = "Something went wrong."
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(textLabel)

        detailTextLabel.text = "Tap to reload"
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.footnote)
        detailTextLabel.font = UIFont(descriptor: fontDescriptor, size: 0)
        detailTextLabel.textAlignment = .center
        detailTextLabel.textColor = UIColor.gray
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(detailTextLabel)

        let views = ["label": textLabel, "detailLabel": detailTextLabel]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-[label]-|", options: .alignAllCenterY, metrics: nil, views: views)

        let hConstraintsDetail = NSLayoutConstraint.constraints(withVisualFormat: "|-[detailLabel]-|",
                options: .alignAllCenterY, metrics: nil, views: views)

        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-[detailLabel]-|",
                options: .alignAllCenterX, metrics: nil, views: views)

        centerView.addConstraints(hConstraints)
        centerView.addConstraints(hConstraintsDetail)
        centerView.addConstraints(vConstraints)
    }
}
