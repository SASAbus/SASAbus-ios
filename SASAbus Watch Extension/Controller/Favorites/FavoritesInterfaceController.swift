import WatchKit
import Foundation

import ObjectMapper


class FavoritesInterfaceController: WKInterfaceController, PhoneMessageListener {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var loadingText: WKInterfaceLabel!
    @IBOutlet var noFavoritesText: WKInterfaceLabel!
    
    var busStops = [BBusStop]()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        PhoneConnection.standard.addListener(self)
        PhoneConnection.standard.sendMessage(message: ["type": WatchMessage.favoriteBusStops.rawValue])
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        PhoneConnection.standard.removeListener(self)
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        pushController(withName: "DeparturesInterfaceController", context: busStops[rowIndex])
    }
}

extension FavoritesInterfaceController {
    
    func didReceiveMessage(type: WatchMessage, data: String, message: [String: Any]) {
        print("didReceiveMessage")
        
        guard type == .favoriteBusStopsResponse else {
            return
        }
        
        guard let items = Mapper<BBusStop>().mapArray(JSONString: data) else {
            Log.error("Cannot map JSON to [BBusStop]")
            return
        }
        
        self.busStops.removeAll()
        self.busStops.append(contentsOf: items)
        
        DispatchQueue.main.async {
            self.loadingText.setHidden(true)
            
            if items.isEmpty {
                self.noFavoritesText.setHidden(false)
            } else {
                self.noFavoritesText.setHidden(true)
            }
            
            self.tableView.setNumberOfRows(self.busStops.count, withRowType: "FavoritesRowController")
            
            for (index, item) in items.enumerated() {
                let row = self.tableView.rowController(at: index) as! FavoritesRowController
                
                row.name.setText(item.name())
                row.city.setText(item.munic())
            }
        }
    }
}
