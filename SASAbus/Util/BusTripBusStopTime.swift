//
// BusTripBusStopTime.swift
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
// along with SASAbus. If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class BusTripBusStopTime {

    let busStop: Int!
    let seconds: Int!

    init(busStop: Int, seconds: Int) {
        self.busStop = busStop
        self.seconds = seconds
    }

    func getTime() -> String {
        let hours = Int(floor(Double(self.seconds) / 60 / 60))
        let hoursString = String(hours)
        let minutes = Int(floor(Double(self.seconds / 60) - Double(hours * 60)))
        var minutesString = String(minutes)

        if minutes < 10 {
            minutesString = "0" + minutesString
        }

        return String(hoursString) + ":" + String(minutesString)
    }
}
