//
//  NearbyInterfaceController.swift
//  SASAbus Watch Extension
//
//  Created by Alex Lardschneider on 28/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import WatchKit
import Foundation

import CoreLocation

class NearbyInterfaceController: WKInterfaceController {

    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var loadingText: WKInterfaceLabel!
    @IBOutlet var noNearbyText: WKInterfaceLabel!
    
    var nearbyBusStops = [BusStopDistance]()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        print("Test")
        
        parseData()
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    
    func parseData() {
        let locationManager = CLLocationManager()
        let lastLocation = locationManager.location
        
        guard let location = lastLocation else {
            Log.error("Cannot map JSON to [BBusStop]")
            
            noNearbyText.setHidden(false)
            loadingText.setHidden(true)
            
            return
        }
        
        DispatchQueue.main.async {
            var busStops = BusStopRealmHelper.nearestBusStops(location: location)
            busStops = Array(busStops[0..<5])
            
            self.loadingText.setHidden(true)
            
            if busStops.isEmpty {
                self.noNearbyText.setHidden(false)
                return
            }
            
            self.nearbyBusStops.removeAll()
            self.nearbyBusStops.append(contentsOf: busStops)
            
            self.tableView.setNumberOfRows(self.nearbyBusStops.count, withRowType: "NearbyRowController")
            
            for (index, item) in busStops.enumerated() {
                let row = self.tableView.rowController(at: index) as! NearbyRowController
                
                row.name.setText(item.busStop.name())
                row.city.setText(item.busStop.munic())
            }
        }
    }
}

