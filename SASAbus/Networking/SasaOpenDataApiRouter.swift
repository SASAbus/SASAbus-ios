//
// SasaOpenDataApiRouter.swift
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

enum SasaOpenDataApiRouter: URLRequestConvertible {
    static let baseURLString = Configuration.dataUrl
    
    // APIs exposed
    case GetExpirationDate()
    
    var method: Alamofire.Method {
        switch self {
        case .GetExpirationDate:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetExpirationDate:
            return "?type=\(SasaDataHelper.ExpirationDate)"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: SasaOpenDataApiRouter.baseURLString + path)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.timeoutInterval = Configuration.timeoutInterval
        return mutableURLRequest
    }
}