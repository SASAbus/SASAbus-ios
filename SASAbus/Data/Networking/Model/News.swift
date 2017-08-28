//
// NewsItem.swift
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
import SwiftyJSON

final class News: JSONable {

    let id: Int

    let title: String
    let message: String

    let lines: [Int]

    let zone: String

    let lastModified: Int

    required init(parameter: JSON) {
        id = parameter["id"].intValue

        title = parameter["title"].stringValue
        message = parameter["message"].stringValue

        lines = parameter["lines"].arrayValue.map {
            $0.intValue
        }

        zone = parameter["zone"].stringValue
        lastModified = parameter["modified"].intValue
    }

    func getLinesString() -> String {
        var linesString = ""

        if self.lines.count > 0 {
            let stringArray: [String] = lines.flatMap { String($0) }

            linesString = Lines.lines(name: stringArray.joined(separator: ", "))
        }

        return linesString
    }
}
