//
//  NearbyRowController.swift
//  SASAbus Watch Extension
//
//  Created by Alex Lardschneider on 02/10/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import WatchKit

class NearbyRowController: NSObject {
    
    @IBOutlet var separator: WKInterfaceSeparator!
    
    @IBOutlet var name: WKInterfaceLabel!
    @IBOutlet var city: WKInterfaceLabel!
}
