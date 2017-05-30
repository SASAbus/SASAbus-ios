import Foundation
import MapKit

class BusStopAnnotation: NSObject, MKAnnotation {

    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let color: UIColor
    let busStop: BusStop

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D,
         busStop: BusStop, color: UIColor = UIColor.red) {

        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.color = color
        self.busStop = busStop

        super.init()
    }
}
