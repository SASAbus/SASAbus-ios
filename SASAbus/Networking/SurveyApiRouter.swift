//
// SurveyApiRouter.swift
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

enum SurveyApiRouter: URLRequestConvertible {
    static let baseURLString = Configuration.surveyApiUrl
    
    // APIs exposed
    case GetSurvey
    case InsertSurvey([String: AnyObject])
    
    var method: Alamofire.Method {
        switch self {
        case .GetSurvey:
            return .POST
        case .InsertSurvey:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .GetSurvey:
            return "/get-survey"
        case .InsertSurvey:
            return "/insert-survey"
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: SurveyApiRouter.baseURLString + path)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        //basic auth
        let credentialData = "\(Configuration.surveyApiUsername):\(Configuration.surveyApiPassword)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        mutableURLRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        switch self {
            /*...*/
            case .InsertSurvey(let parameters):
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            default: //for GET methods, that doesent need more
                return mutableURLRequest
        }
    }
}