//
// ParkingApiRouter.swift
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
import Alamofire

enum ParkingApiRouter: URLRequestConvertible {
    static let baseURLString = Configuration.parkingLotBaseUrl
    
    // APIs exposed
    case GetParkingIds()
    case GetParkingStation(Int)
    case GetNumberOfFreeSlots(Int)
    
    var method: Alamofire.Method {
        switch self {
        case .GetParkingIds:
            return .GET
        case .GetParkingStation:
            return .GET
        case .GetNumberOfFreeSlots:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetParkingIds:
            return "/getParkingIds"
        case .GetParkingStation(let identifier):
            return "/getParkingStation?identifier=\(identifier)" ;
        case .GetNumberOfFreeSlots(let identifier):
            return "/getNumberOfFreeSlots?identifier=\(identifier)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: ParkingApiRouter.baseURLString + path)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.timeoutInterval = Configuration.timeoutInterval
        return mutableURLRequest
    }
}