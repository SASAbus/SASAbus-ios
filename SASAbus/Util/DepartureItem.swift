//
// DepartureItem.swift
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

class DepartureItem {
    
    let busTripStopTime: BusTripBusStopTime
    let destinationBusStation: BusStationItem?
    let busLine: Line!
    let busStopNumber: Int!
    let text: String!
    let stopTimes: [BusTripBusStopTime]!
    let index: Int!
    let departureIndex: Int!
    let delaySecondsRounded: Int!
    let delayStopFoundIndex: Int!
    let realTime: Bool
    let positionItem: RealtimeBus?

    init(busTripStopTime: BusTripBusStopTime, destinationBusStation: BusStationItem?, busLine: Line, 
         busStopNumber: Int, text: String, stopTimes: [BusTripBusStopTime], index: Int, departureIndex: Int, 
         delaySecondsRounded: Int, delayStopFoundIndex: Int, realTime: Bool, positionItem: RealtimeBus?) {
        
        self.busTripStopTime = busTripStopTime
        self.destinationBusStation = destinationBusStation
        self.busStopNumber = busStopNumber
        self.busLine = busLine
        self.text = text
        self.stopTimes = stopTimes
        self.index = index
        self.departureIndex = departureIndex
        self.delaySecondsRounded = delaySecondsRounded
        self.delayStopFoundIndex = delayStopFoundIndex
        self.realTime = realTime
        self.positionItem = positionItem
    }
}
