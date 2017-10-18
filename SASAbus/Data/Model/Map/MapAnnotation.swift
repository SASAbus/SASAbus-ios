import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var pinColor: UIColor
    
    dynamic var coordinate: CLLocationCoordinate2D
    
    var busData: RealtimeBus
    
    var selected: Bool
    
    init(title: String, coordinate: CLLocationCoordinate2D, pinColor: UIColor, data: RealtimeBus) {
        self.title = title
        self.subtitle = ""
        self.coordinate = coordinate
        self.pinColor = pinColor
        self.busData = data
        self.selected = false
        
        super.init()
    }
}
