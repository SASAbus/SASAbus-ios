//
//  MainInterfaceController.swift
//  SASAbus Watch Extension
//
//  Created by Alex Lardschneider on 27/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import WatchKit
import Foundation

class MainInterfaceController: WKInterfaceController {
    
    let color = UIColor(hue: 0.08, saturation: 0.85, brightness: 0.90, alpha: 1)

    @IBOutlet var nearbyButton: WKInterfaceButton!
    @IBOutlet var recentButton: WKInterfaceButton!
    @IBOutlet var favoritesButton: WKInterfaceButton!
    @IBOutlet var searchButton: WKInterfaceButton!
    
    @IBOutlet var nearbyIcon: WKInterfaceImage!
    @IBOutlet var recentIcon: WKInterfaceImage!
    @IBOutlet var favoritesIcon: WKInterfaceImage!
    @IBOutlet var searchIcon: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        nearbyIcon.setTintColor(color)
        recentIcon.setTintColor(color)
        favoritesIcon.setTintColor(color)
        searchIcon.setTintColor(color)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func onNearbyClick() {
    }
}
