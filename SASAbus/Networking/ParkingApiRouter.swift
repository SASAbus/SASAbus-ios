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

    static let baseURLString = Config.parkingLotBaseUrl

    // APIs exposed
    case getParkingIds()
    case getParkingStation(Int)
    case getNumberOfFreeSlots(Int)

    var method: HTTPMethod {
        switch self {
        case .getParkingIds:
            return .get
        case .getParkingStation:
            return .get
        case .getNumberOfFreeSlots:
            return .get
        }
    }

    var path: String {
        switch self {
        case .getParkingIds:
            return "/getParkingIds"
        case .getParkingStation(let identifier):
            return "/getParkingStation?identifier=\(identifier)"
        case .getNumberOfFreeSlots(let identifier):
            return "/getNumberOfFreeSlots?identifier=\(identifier)"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = URL(string: ParkingApiRouter.baseURLString + path)!
        let mutableURLRequest = NSMutableURLRequest(url: url)

        mutableURLRequest.httpMethod = method.rawValue
        mutableURLRequest.timeoutInterval = Config.timeoutInterval
        return mutableURLRequest as URLRequest
    }
}
