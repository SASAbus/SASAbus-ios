//
// SurveyLocationHandler.swift
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

import Foundation
import CoreLocation

class SurveyLocationHandler: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    var locationFoundProtocol: LocationFoundProtocol!
    var locationAquired: Bool!

    init(locationFoundProtocol: LocationFoundProtocol) {
        super.init()
        self.locationAquired = false
        self.locationFoundProtocol = locationFoundProtocol
    }


    func getLocationAsync() {
        self.locationManager = CLLocationManager()
        // Ask for Authorisation from the User.
        self.locationManager!.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager!.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager!.delegate = self
            self.locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager!.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //first stop locationmanager from updating
        if self.locationAquired == false {
            self.locationAquired = true
            if locationManager != nil {
                self.locationManager?.stopUpdatingLocation()
            }

            let locationArray = locations as NSArray
            let location = locationArray.lastObject as? CLLocation
            if location != nil {
                self.locationFoundProtocol.found(location!)
            }
        }
    }
}
