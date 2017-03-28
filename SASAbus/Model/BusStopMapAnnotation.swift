//
// Created by Alex Lardschneider on 28/03/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import MapKit

class BusStopMapAnnotation: NSObject, MKAnnotation {

    var title: String?
    var subtitle: String?
    var pinColor: UIColor

    var id: Int

    dynamic var coordinate: CLLocationCoordinate2D

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, id: Int) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.pinColor = Color.red

        self.id = id

        super.init()
    }
}
