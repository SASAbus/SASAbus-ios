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
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestAlwaysAuthorization()
        
        let lastLocation = locationManager.location
        
        guard let location = lastLocation else {
            Log.error("Cannot get last location")
            
            noNearbyText.setHidden(false)
            loadingText.setHidden(true)
            
            return
        }
        
        Log.info("Location: \(location)")
        
        DispatchQueue.main.async {
            let busStops = BusStopRealmHelper.nearestBusStops(location: location, count: 10)
            
            self.nearbyBusStops.removeAll()
            self.nearbyBusStops.append(contentsOf: busStops)
            
            self.loadingText.setHidden(true)
            
            if busStops.isEmpty {
                self.noNearbyText.setHidden(false)
                return
            } else {
                self.noNearbyText.setHidden(true)
            }
            
            self.tableView.setNumberOfRows(self.nearbyBusStops.count, withRowType: "NearbyRowController")
            
            for (index, item) in busStops.enumerated() {
                let row = self.tableView.rowController(at: index) as! NearbyRowController
                
                row.name.setText(item.busStop.name())
                row.city.setText(item.busStop.munic())
            }
        }
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "DeparturesInterfaceController", context: nearbyBusStops[rowIndex].busStop)
    }
}

