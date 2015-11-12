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
        let nibView = NSBundle.mainBundle().loadNibNamed("BackgroundView", owner: self, options: nil)[0] as! UIView
        nibView.frame = self.bounds;
        self.addSubview(nibView)
        
        self.injectEasterEgg(self, numberOfTapsRequired: 35)
        self.setupProgressIndicator()
    }
    
    func injectEasterEgg(target:UIView, numberOfTapsRequired:Int) {
        let bSelector : Selector = "tap:"
        let doubleTapGesture =  UITapGestureRecognizer(target: target, action: bSelector)
        doubleTapGesture.numberOfTapsRequired = numberOfTapsRequired
        target.addGestureRecognizer(doubleTapGesture)
    }
    
    @IBAction func tap(sender: AnyObject){
        backgroundImageView.image = UIImage(named: "system_preference_layer")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupProgressIndicator() {
        self.progressIndicatorView.angle = 0
        self.progressIndicatorView.progressThickness = 0.04
        self.progressIndicatorView.trackThickness = 0.05
        self.progressIndicatorView.clockwise = true
        self.progressIndicatorView.center = self.center
        self.progressIndicatorView.gradientRotateSpeed = 100
        self.progressIndicatorView.roundedCorners = true
        self.progressIndicatorView.glowMode = .NoGlow
        self.progressIndicatorView.trackColor = Theme.colorWhite
        self.progressIndicatorView.setColors(Theme.colorOrange ,Theme.colorOrange, Theme.colorOrange)
        self.progressIndicatorView.hidden = false
    }
}
