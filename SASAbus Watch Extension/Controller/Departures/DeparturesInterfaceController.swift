//
//  DeparturesInterfaceController.swift
//  SASAbus Watch Extension
//
//  Created by Alex Lardschneider on 29/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import WatchKit
import Foundation

import ObjectMapper


class DeparturesInterfaceController: WKInterfaceController, PhoneMessageListener {

    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var loadingText: WKInterfaceLabel!
    @IBOutlet var noDeparturesText: WKInterfaceLabel!
    
    var busStop: BBusStop!
    var departures = [Departure]()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        busStop = context as! BBusStop
    }

    override func willActivate() {
        super.willActivate()
        
        PhoneConnection.standard.addListener(self)
        
        PhoneConnection.standard.sendMessage(message: [
            "type": WatchMessage.calculateDepartures.rawValue,
            "bus_stop_group": busStop.family
        ])
        
        // This method is called when watch view controller is about to be visible to user
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        PhoneConnection.standard.removeListener(self)
        
        // This method is called when watch view controller is no longer visible
    }
}

extension DeparturesInterfaceController {
    
    func didReceiveMessage(type: WatchMessage, data: String) {
        print("didReceiveMessage")
        
        guard type == .calculateDeparturesResponse else {
            return
        }
        
        guard let items = Mapper<Departure>().mapArray(JSONString: data) else {
            Log.error("Cannot map JSON to [Departure]")
            return
        }
        
        DispatchQueue.main.async {
            self.loadingText.setHidden(true)
            
            if items.isEmpty {
                self.noDeparturesText.setHidden(false)
                return
            }
            
            self.departures.removeAll()
            self.departures.append(contentsOf: items)
            
            self.tableView.setNumberOfRows(self.departures.count, withRowType: "DeparturesRowController")
            
            for (index, item) in items.enumerated() {
                let row = self.tableView.rowController(at: index) as! DeparturesRowController
                
                row.line.setText(item.line)
                row.destination.setText(L10n.General.headingToShort(item.destination))
                row.time.setText(item.time)
            }
        }
    }
}
