//
//  RecentInterfaceController.swift
//  SASAbus Watch Extension
//
//  Created by Alex Lardschneider on 28/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import WatchKit
import Foundation

import ObjectMapper


class RecentInterfaceController: WKInterfaceController, PhoneMessageListener {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var loadingText: WKInterfaceLabel!
    @IBOutlet var noRecentsText: WKInterfaceLabel!
    
    var busStops = [BBusStop]()
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

    override func willActivate() {
        super.willActivate()
        
        PhoneConnection.standard.addListener(self)
        PhoneConnection.standard.sendMessage(message: ["type": WatchMessage.recentBusStops.rawValue])
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        PhoneConnection.standard.removeListener(self)
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "DeparturesInterfaceController", context: busStops[rowIndex])
    }
}

extension RecentInterfaceController {
    
    func didReceiveMessage(type: WatchMessage, data: String) {
        print("didReceiveMessage")
        
        guard type == .nearbyBusStopsResponse else {
            return
        }
        
        guard let items = Mapper<BBusStop>().mapArray(JSONString: data) else {
            Log.error("Cannot map JSON to [BBusStop]")
            return
        }
        
        DispatchQueue.main.async {
            self.loadingText.setHidden(true)
            
            if items.isEmpty {
                self.noRecentsText.setHidden(false)
                return
            }
            
            self.busStops.removeAll()
            self.busStops.append(contentsOf: items)
            
            self.tableView.setNumberOfRows(self.busStops.count, withRowType: "RecentRowController")
            
            for (index, item) in items.enumerated() {
                let row = self.tableView.rowController(at: index) as! RecentRowController
                
                row.name.setText(item.name())
                row.city.setText(item.munic())
            }
        }
    }
}
