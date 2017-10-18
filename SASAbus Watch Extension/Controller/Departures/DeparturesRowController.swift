import WatchKit

class DeparturesRowController: NSObject {
    
    @IBOutlet var separator: WKInterfaceSeparator!
    
    @IBOutlet var line: WKInterfaceLabel!
    @IBOutlet var destination: WKInterfaceLabel!
    
    @IBOutlet var time: WKInterfaceLabel!
}
