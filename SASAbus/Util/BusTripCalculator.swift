//
// BusTripCalculator.swift
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

class BusTripCalculator {
    
    
    static var standardTimeCache:[String : BusStandardTimeBetweenStopItem]?
    
    static func calculateBusStopTimes(busLineVariantTrip: BusLineVariantTrip) -> [BusTripBusStopTime] {
        
        var stopTimes: [BusTripBusStopTime] = []
        let standardTimes: [BusStandardTimeBetweenStopItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStandardTimeBetweenStopsList) as [BusStandardTimeBetweenStopItem]
        var standardTimesDictionary  = [String : BusStandardTimeBetweenStopItem]()
        
        if standardTimeCache == nil {
            for standardTime in standardTimes {
                standardTimesDictionary[standardTime.getLocationDestinationGroupIdentifier()] = standardTime
            }
            standardTimeCache = standardTimesDictionary
        } else {
            standardTimesDictionary = standardTimeCache!
        }
        
        let exceptionTimes: [BusExceptionTimeBetweenStopItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusExceptionTimeBetweenStops) as [BusExceptionTimeBetweenStopItem]
        let defaultWaitTimes: [BusWaitTimeAtStopItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusWaitTimeAtStopList) as [BusWaitTimeAtStopItem]
        let busDefaultWaitTimes: [BusDefaultWaitTimeAtStopItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusDefaultWaitTimeAtStopList) as [BusDefaultWaitTimeAtStopItem]
        let busLineWaitTimes: [BusLineWaitTimeAtStopItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusLineWaitTimeAtStopList) as [BusLineWaitTimeAtStopItem]
        let busPaths: [BusPathItem] = SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusPathList) as [BusPathItem]
        let busPath = busPaths.find({$0.getLineNumber() == busLineVariantTrip.getBusLine().getNumber()})
        if (busPath != nil) {
            let variant = busPath?.getVariants().find({$0.getVariantNumber() == busLineVariantTrip.getVariant().getVariant()})
            if (variant != nil) {
                let busStops = variant!.getBusStops()
                let busStopsCount = busStops.count
                var currentTime = busLineVariantTrip.getTrip().getStartTime()
                for index in 0...busStopsCount - 1 {
                    let busStop = busStops[index]
                    if (index > 0) {
                        let lastBusStop = busStops[index - 1]
                        let exceptionTime = exceptionTimes.filter({$0.getTripId() == busLineVariantTrip.getTrip().getTripId()}).find({$0.getLocationNumber() == lastBusStop})
                        if (exceptionTime != nil) {
                            currentTime = currentTime + exceptionTime!.getExceptionTime()
                        } else {
                            let standardTimeIdentifier:String = [
                                    String(lastBusStop),
                                    String(busStop),
                                    String(busLineVariantTrip.getTrip().getGroupNumber())
                                ].joinWithSeparator(":")
                            
                            let standardTime = standardTimesDictionary[standardTimeIdentifier]
                                                      
                            if (standardTime != nil) {
                                currentTime = currentTime + standardTime!.getStandardTime()
                            }
                        }
                        if (index < busStopsCount - 1) {
                            let defaultWaitTime = defaultWaitTimes.filter({$0.getTripId() == busLineVariantTrip.getTrip().getTripId()}).find({$0.getLocationNumber() == busStop})
                            if (defaultWaitTime != nil) {
                                currentTime = currentTime + defaultWaitTime!.getWaitTime()
                            } else {
                                let busWaitTime = busLineWaitTimes.filter({$0.getLineNumber() == busLineVariantTrip.getBusLine().getNumber()}).filter({$0.getVariantNumber() == busLineVariantTrip.getVariant().getVariant()}).filter({$0.getGroupNumber() == busLineVariantTrip.getTrip().getGroupNumber()}).find({$0.getBusStopOfTrip() == index + 1})
                                if (busWaitTime != nil) {
                                    currentTime = currentTime + busWaitTime!.getWaitTime()
                                } else {
                                    let busDefaultWaitTime = busDefaultWaitTimes.filter({$0.getLocationNumber() == busStop}).find({$0.getGroupNumber() == busLineVariantTrip.getTrip().getGroupNumber()})
                                    if (busDefaultWaitTime != nil) {
                                        currentTime = currentTime + busDefaultWaitTime!.getWaitTime()
                                    }
                                }
                            }
                        }
                    }
                    stopTimes.append(BusTripBusStopTime(busStop: busStop, seconds: currentTime))
                }
            }
        }
        stopTimes.sortInPlace({$0.getSeconds() < $1.getSeconds()})
        return stopTimes
    }
}