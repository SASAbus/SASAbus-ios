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
    private let busTripStopTime: BusTripBusStopTime
    private let destinationBusStation: BusStationItem?
    private let busLine: BusLineItem!
    private let busStopNumber: Int!
    private let text: String!
    private let stopTimes: [BusTripBusStopTime]!
    private let index: Int!
    private let departureIndex: Int!
    private let delaySecondsRounded: Int!
    private let delayStopFoundIndex: Int!
    private let realTime: Bool!
    private let positionItem: PositionItem?
    
    init(busTripStopTime: BusTripBusStopTime, destinationBusStation: BusStationItem?, busLine: BusLineItem, busStopNumber: Int, text: String, stopTimes: [BusTripBusStopTime], index: Int, departureIndex: Int, delaySecondsRounded: Int, delayStopFoundIndex: Int, realTime: Bool, positionItem: PositionItem?) {
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
    
    func getBusTripStopTime() -> BusTripBusStopTime {
        return self.busTripStopTime
    }
    
    func getDestinationBusStation() -> BusStationItem? {
        return self.destinationBusStation
    }
    
    func getBusLine() -> BusLineItem {
        return self.busLine
    }
    
    func getBusStopNumber() -> Int {
        return self.busStopNumber
    }
    
    func getText() -> String {
        return self.text
    }
    
    func getStopTimes() -> [BusTripBusStopTime] {
        return self.stopTimes
    }
    
    func getIndex() -> Int {
        return self.index
    }
    
    func getDepartureIndex() -> Int {
        return self.departureIndex
    }
    
    func getDelaySecondsRounded() -> Int {
        return self.delaySecondsRounded
    }
    
    func getDelayStopFoundIndex() -> Int {
        return self.delayStopFoundIndex
    }
    
    func isRealTime() -> Bool {
        return self.realTime
    }
    
    func getPositionItem() -> PositionItem? {
        return self.positionItem
    }
}