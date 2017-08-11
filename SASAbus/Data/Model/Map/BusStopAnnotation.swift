import Foundation
import MapKit

class BusStopAnnotation: NSObject, MKAnnotation {

    let title: String?
    let subtitle: String?

    let color: UIColor
    let busStop: BBusStop

    let coordinate: CLLocationCoordinate2D

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D,
         busStop: BBusStop, color: UIColor = UIColor.red) {

        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.color = color
        self.busStop = busStop

        super.init()
    }
}
