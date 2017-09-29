//
//  DeparturesRowController.swift
//  SASAbus Watch Extension
//
//  Created by Alex Lardschneider on 29/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import WatchKit

class DeparturesRowController: NSObject {
    
    @IBOutlet var separator: WKInterfaceSeparator!
    
    @IBOutlet var line: WKInterfaceLabel!
    @IBOutlet var destination: WKInterfaceLabel!
    
    @IBOutlet var time: WKInterfaceLabel!
}
