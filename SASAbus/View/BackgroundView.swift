//
// BackgroundView.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import KDCircularProgress

class BackgroundView: UIView {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var progressIndicatorView: KDCircularProgress!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let nibView = Bundle.main.loadNibNamed("BackgroundView", owner: self, options: nil)?[0] as! UIView
        nibView.frame = self.bounds
        self.addSubview(nibView)

        injectEasterEgg(self)
        setupProgressIndicator()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    func injectEasterEgg(_ target: UIView) {
        let bSelector: Selector = #selector(BackgroundView.tap(_:))
        let doubleTapGesture = UITapGestureRecognizer(target: target, action: bSelector)

        doubleTapGesture.numberOfTapsRequired = 5
        target.addGestureRecognizer(doubleTapGesture)
    }

    func setupProgressIndicator() {
        progressIndicatorView.angle = 0
        progressIndicatorView.progressThickness = 0.04
        progressIndicatorView.trackThickness = 0.05
        progressIndicatorView.clockwise = true
        progressIndicatorView.center = center
        progressIndicatorView.gradientRotateSpeed = 100
        progressIndicatorView.roundedCorners = true
        progressIndicatorView.glowMode = .noGlow
        progressIndicatorView.trackColor = Theme.white
        progressIndicatorView.set(colors: Theme.orange, Theme.orange, Theme.orange)
        progressIndicatorView.isHidden = false
    }


    @IBAction func tap(_ sender: AnyObject) {
        backgroundImageView.image = UIImage(named: "system_preference_layer")
    }
}
