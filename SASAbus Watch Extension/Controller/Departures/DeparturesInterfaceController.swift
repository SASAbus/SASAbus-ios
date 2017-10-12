import WatchKit
import Foundation

import ObjectMapper


class DeparturesInterfaceController: WKInterfaceController, PhoneMessageListener {

    @IBOutlet var tableView: WKInterfaceTable!
    
    @IBOutlet var loadingText: WKInterfaceLabel!
    @IBOutlet var noDeparturesText: WKInterfaceLabel!
    
    var busStop: BBusStop!
    var departures = [Departure]()
    
    var isInFavorites = false
    
    
    override func awake(withContext context: Any?) {
        Log.error("AWAKE")
        
        super.awake(withContext: context)
        
        busStop = context as! BBusStop
        
        PhoneConnection.standard.addListener(self)
        
        PhoneConnection.standard.sendMessage(message: [
            "type": WatchMessage.calculateDepartures.rawValue,
            "bus_stop_group": busStop.family
            ])
    }

    override func willActivate() {
        super.willActivate()
        
        PhoneConnection.standard.addListener(self)
    }

    override func didDeactivate() {
        super.didDeactivate()
        
        PhoneConnection.standard.removeListener(self)
    }

    
    func toggleFavoriteState() {
        Log.warning("Toggling favorite state to \(!isInFavorites)")
        
        var message = [String: Any]()
        message["type"] = WatchMessage.setBusStopFavorite.rawValue
        message["bus_stop"] = busStop.family
        message["is_favorite"] = !isInFavorites
        
        isInFavorites = !isInFavorites
        
        PhoneConnection.standard.sendMessageWithoutReply(message: message)
        
        setFavoriteMenuItem()
    }
    
    func setFavoriteMenuItem() {
        clearAllMenuItems()
        
        if isInFavorites {
            addMenuItem(with: Asset.icStarWhite.image, title: "Remove from favorites", action: #selector(toggleFavoriteState))
        } else {
            addMenuItem(with: Asset.icStarBorderWhite.image, title: "Add to favorites", action: #selector(toggleFavoriteState))
        }
    }
}

extension DeparturesInterfaceController {
    
    func didReceiveMessage(type: WatchMessage, data: String, message: [String: Any]) {
        print("didReceiveMessage")
        
        guard type == .calculateDeparturesResponse else {
            return
        }
        
        guard let items = Mapper<Departure>().mapArray(JSONString: data) else {
            Log.error("Cannot map JSON to [Departure]")
            return
        }
        
        guard let isFavorite = message["is_favorite"] as? Bool else {
            Log.error("Unknown favorite status for bus stop \(busStop.family)")
            return
        }

        isInFavorites = isFavorite
        
        DispatchQueue.main.async {
            self.setFavoriteMenuItem()
            
            self.loadingText.setHidden(true)
            
            if items.isEmpty {
                Log.warning("No departures provided")
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
