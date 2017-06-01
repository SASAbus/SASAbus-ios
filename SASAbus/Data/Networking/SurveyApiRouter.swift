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

import Alamofire

enum SurveyApiRouter: URLRequestConvertible {

    static let baseURLString = Config.surveyApiUrl

    // APIs exposed
    case getSurvey
    case insertSurvey([String : AnyObject])

    var method: HTTPMethod {
        switch self {
        case .getSurvey:
            return .post
        case .insertSurvey:
            return .post
        }
    }

    var path: String {
        switch self {
        case .getSurvey:
            return "/get-survey"
        case .insertSurvey:
            return "/insert-survey"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = URL(string: SurveyApiRouter.baseURLString + path)!
        let mutableURLRequest = NSMutableURLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue

        //basic auth
        let credentials = "\(Config.surveyApiUsername):\(Config.surveyApiPassword)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentials.base64EncodedString()

        mutableURLRequest.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

        switch self {
        case .insertSurvey(let parameters):
            return try! Alamofire.URLEncoding.default.encode(mutableURLRequest as!
            URLRequestConvertible, with: parameters) as URLRequest
        default: // For GET methods, that doesent need more
            return mutableURLRequest as URLRequest
        }
    }
}
