import WatchKit
import Foundation

import Realm
import RealmSwift

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
    
    
    @IBAction func onSearchButtonPress() {
        displaySearch()
    }
    
    private func displaySearch() {
        var defaults = [String]()
        let realm = Realm.busStops()
        
        var filterChain = ""
        
        for id in SearchInterfaceController.defaultBusStopsIds {
            filterChain += "family == \(id) OR "
        }
        
        filterChain = filterChain.substring(to: filterChain.index(filterChain.endIndex, offsetBy: -5))
        
        let busStops = realm.objects(BusStop.self).filter(filterChain)
        for busStop in busStops {
            defaults.append(busStop.name())
        }
        
        // Filter out duplicate bus stops
        defaults = defaults.uniques().sorted()
        
        dump(defaults)
        
        presentTextInputController(withSuggestions: defaults, allowedInputMode: .plain, completion: {(results) -> Void in
            guard let results = results, !results.isEmpty else {
                Log.warning("No results returned")
                self.popToRootController()
                return
            }
            
            let busStop = results[0] as! String
            Log.info("Searched for '\(busStop)'")
            
            self.pushController(withName: "SearchInterfaceController", context: busStop)
        })
    }
}
