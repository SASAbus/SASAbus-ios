//
// BusstopMapViewController.swift
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

class BusStopMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    var locationManager: CLLocationManager?
    var realm = Realm.busStops()

    init() {
        super.init(nibName: "BusStopMapViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Bus stations map", comment: "")
        self.locationManager = CLLocationManager()

        self.locationManager = CLLocationManager()

        mapView.delegate = self
        mapView.mapType = Settings.getMapType()!

        mapView.setRegion(Config.mapRegion, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.locationManager!.stopUpdatingLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.locationManager!.requestAlwaysAuthorization()
        self.locationManager!.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager!.startUpdatingLocation()
        }

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
        let annotation = view.annotation as! BusStopMapAnnotation
        let id = annotation.id

        if control == view.rightCalloutAccessoryView {
            Log.warning("Clicked on \(id)")

            var busStopViewController: BusStopViewController!

            let busStop = BBusStop(fromRealm: realm.objects(BusStop.self).filter("id == \(id)").first!)

            if (self.navigationController?.viewControllers.count)! > 1 {
                busStopViewController = self.navigationController?
                        .viewControllers[(self.navigationController?
                        .viewControllers.index(of: self))! - 1] as? BusStopViewController

                busStopViewController!.setBusStop(busStop)
                self.navigationController?.popViewController(animated: true)
            } else {
                busStopViewController = BusStopViewController(busStop: busStop, title: NSLocalizedString("Busstop", comment: ""))
                (UIApplication.shared.delegate as! AppDelegate).navigateTo(busStopViewController!)
            }
        }
    }


    func parseData() {
        let busStops = BusStopRealmHelper.all()

        for busStop in busStops {
            let annotation = BusStopMapAnnotation(
                    title: busStop.name(locale: Utils.locale()),
                    subtitle: busStop.munic(locale: Utils.locale()),
                    coordinate: CLLocationCoordinate2D(latitude: Double(busStop.lat), longitude: Double(busStop.lng)),
                    id: busStop.id
            )

            mapView.addAnnotation(annotation)
        }
    }
}
