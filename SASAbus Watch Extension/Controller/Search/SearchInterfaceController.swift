import WatchKit
import Foundation

import Realm
import RealmSwift


class SearchInterfaceController: WKInterfaceController {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var loadingText: WKInterfaceLabel!
    @IBOutlet var noResultsText: WKInterfaceLabel!
    
    var foundBusStops = [BBusStop]()
    
    public static let defaultBusStopsIds = [
        61,  // Casanova
        102, // Fiera
        105, // Firmian
        175, // Ospedale
        209, // Piazza Domenicani
        227, // Piazza Vittoria (Via Cesare Battisti)
        544, // Piazza Vittoria (Corso Libertà)
        229, // Piazza Walther
        449  // Via Perathoner
    ]
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let query = context as? String {
            searchBusStops(query: query)
        }
    }

    override func willActivate() {
        super.willActivate()
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
                    self.loadingText.setHidden(true)
                    self.noResultsText.setHidden(false)
                }
                
                return
            }
           
            var mapped = busStops.map { stop -> BBusStop in
                BBusStop(fromRealm: stop)
            }
            
            mapped = mapped.uniques()
            
            self.foundBusStops.removeAll()
            self.foundBusStops.append(contentsOf: mapped)
            
            DispatchQueue.main.async {
                self.loadingText.setHidden(true)
                self.noResultsText.setHidden(true)
                
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
