//
// ParkingStationItem.swift
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

import CoreLocation

final class ParkingStationItem: ResponseObjectSerializable {
    private let phone: String
    private let status: Int
    private let address: String
    private let slots: Int
    private let description: String
    private let name: String
    private let location: CLLocation
    
    init?(representation: AnyObject) {
        self.phone = representation.valueForKeyPath("phone") as! String
        self.status = representation.valueForKeyPath("status") as! Int
        self.address = representation.valueForKeyPath("address") as! String
        self.slots = representation.valueForKeyPath("slots") as! Int
        self.description = representation.valueForKeyPath("description") as! String
        self.name = representation.valueForKeyPath("name") as! String
        let longitude: CLLocationDegrees = representation.valueForKeyPath("longitude") as! Double
        let latitude: CLLocationDegrees = representation.valueForKeyPath("latitude") as! Double
        self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
    
    /*static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [ParkingStationItem] {
    var parkingStationItems: [ParkingStationItem] = []
    
    if let representation = representation as? [[String: AnyObject]] {
    for parkingStationRepresentation in representation {
    if let parkingStationItem = ParkingStationItem(response: response, representation: parkingStationRepresentation) {
    parkingStationItems.append(parkingStationItem)
    }
    }
    }
    
    return parkingStationItems
    }*/
    
    func getName() -> String {
        return self.name
    }
    
    func getAddress() -> String {
        return self.address
    }
    
    func getPhone() -> String {
        return self.phone
    }
    
    func getSlots() -> Int {
        return self.slots
    }
    
    func getLocation() -> CLLocation {
        return self.location
    }
}