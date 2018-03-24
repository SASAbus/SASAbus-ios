//
// BusStopMapViewController.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class BusStopMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var realm = Realm.busStops()

    init() {
        super.init(nibName: "BusStopMapViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Departures.Map.title
    
        mapView.delegate = self
        mapView.mapType = MapUtils.getMapType()

        mapView.setRegion(MapUtils.getRegion(), animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        parseData()
    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView

        if pinView == nil {
            let calloutButton = UIButton(type: .detailDisclosure)

            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = calloutButton
            pinView!.sizeToFit()
        } else {
            pinView!.annotation = annotation
        }


        return pinView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! BusStopAnnotation
        let id = annotation.busStop.id

        if control == view.rightCalloutAccessoryView {
            Log.warning("Clicked on \(id)")

            var viewController: BusStopViewController!
            
            if (self.navigationController?.viewControllers.count)! > 1 {
                viewController = self.navigationController?
                        .viewControllers[(self.navigationController?
                        .viewControllers.index(of: self))! - 1] as? BusStopViewController

                viewController!.setBusStop(annotation.busStop)
                self.navigationController?.popViewController(animated: true)
            } else {
                viewController = BusStopViewController(busStop: annotation.busStop)
                (UIApplication.shared.delegate as! AppDelegate).navigateTo(viewController!)
            }
        }
    }


    func parseData() {
        let busStops = BusStopRealmHelper.all()

        for busStop in busStops {
            let annotation = BusStopAnnotation(
                    title: busStop.name(locale: Locales.get()),
                    subtitle: busStop.munic(locale: Locales.get()),
                    coordinate: CLLocationCoordinate2D(latitude: Double(busStop.lat), longitude: Double(busStop.lng)),
                    busStop: BBusStop(fromRealm: busStop)
            )

            mapView.addAnnotation(annotation)
        }
    }
}
