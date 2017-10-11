import WatchKit
import Foundation

import Realm
import RealmSwift


class SearchInterfaceController: WKInterfaceController {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var loadingText: WKInterfaceLabel!
    @IBOutlet var noResultsText: WKInterfaceLabel!
    
    var foundBusStops = [BBusStop]()
    
    let defaultBusStopsIds = [
        61,  // Casanova
        102, // Fiera
        105, // Firmian
        175, // Ospedale
        209, // Piazza Domenicani
        227, // Piazza Vittoria (Via Cesare Battisti)
        544, // Piazza Vittoria (Corso Libertà)
        229, // Piazza Walther
        449, // Via Perathoner
        461  // Via Resia S. Pio X
    ]
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }

    override func willActivate() {
        super.willActivate()
        
        var defaults = [String]()
        let realm = Realm.busStops()
        
        var filterChain = ""
        
        for id in defaultBusStopsIds {
            filterChain += "family == \(id) OR "
        }
        
        filterChain = filterChain.substring(to: filterChain.index(filterChain.endIndex, offsetBy: -5))
        
        let busStops = realm.objects(BusStop.self).filter(filterChain)
        for busStop in busStops {
            defaults.append(busStop.name())
        }
    
        // Filter out duplicate bus stops
        defaults = Array(Set(defaults)).sorted()
        
        dump(defaults)
        
        presentTextInputController(withSuggestions: defaults, allowedInputMode: .plain, completion: {(results) -> Void in
            guard let results = results, !results.isEmpty else {
                Log.warning("No results returned")
                self.popToRootController()
                return
            }
            
            let busStop = results[0] as! String
            Log.info("Searched for '\(busStop)'")
            
            self.searchBusStops(query: busStop)
        })
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    

    func searchBusStops(query: String) {
        DispatchQueue.global(qos: .background).async {
            let realm = Realm.busStops()
            
            let busStops = realm.objects(BusStop.self)
                .filter("nameDe CONTAINS[c] '\(query)' OR nameIt CONTAINS[c] '\(query)'")
                .prefix(10)
            
            if busStops.isEmpty {
                DispatchQueue.main.async {
                    self.noResultsText.setHidden(false)
                }
                
                return
            }
           
            var mapped = busStops.map { stop -> BBusStop in
                BBusStop(fromRealm: stop)
            }
            
            mapped = Array(Set(mapped))
            
            self.foundBusStops.removeAll()
            self.foundBusStops.append(contentsOf: mapped)
            
            DispatchQueue.main.async {
                self.loadingText.setHidden(true)
                
                self.tableView.setNumberOfRows(self.foundBusStops.count, withRowType: "SearchRowController")
                
                for (index, item) in self.foundBusStops.enumerated() {
                    let row = self.tableView.rowController(at: index) as! SearchRowController
                    
                    row.name.setText(item.name())
                    row.city.setText(item.munic())
                }
            }
        }
    }

    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "DeparturesInterfaceController", context: foundBusStops[rowIndex])
    }
}
