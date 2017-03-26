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


    static var standardTimeCache: [String: BusStandardTimeBetweenStopItem]?

    static func calculateBusStopTimes(_ busLineVariantTrip: BusLineVariantTrip) -> [BusTripBusStopTime] {

        var stopTimes: [BusTripBusStopTime] = []
        let standardTimes: [BusStandardTimeBetweenStopItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.SEL_FZT_FELD) as [BusStandardTimeBetweenStopItem]
        var standardTimesDictionary = [String: BusStandardTimeBetweenStopItem]()

        if standardTimeCache == nil {
            for standardTime in standardTimes {
                standardTimesDictionary[standardTime.locationDestinationGroupIdentifier] = standardTime
            }
            standardTimeCache = standardTimesDictionary
        } else {
            standardTimesDictionary = standardTimeCache!
        }

        let exceptionTimes: [BusExceptionTimeBetweenStopItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_FRT_FZT) as [BusExceptionTimeBetweenStopItem]
        let defaultWaitTimes: [BusWaitTimeAtStopItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_FRT_HZT) as [BusWaitTimeAtStopItem]
        let busDefaultWaitTimes: [BusDefaultWaitTimeAtStopItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.ORT_HZT) as [BusDefaultWaitTimeAtStopItem]
        let busLineWaitTimes: [BusLineWaitTimeAtStopItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.REC_LIVAR_HZT) as [BusLineWaitTimeAtStopItem]
        let busPaths: [BusPathItem] = SasaDataHelper.getDataForRepresentation(SasaDataHelper.LID_VERLAUF) as [BusPathItem]
        let busPath = busPaths.find(predicate: { $0.lineNumber == busLineVariantTrip.busLine.id })

        if (busPath != nil) {
            let variant = busPath?.variants.find(predicate: { $0.variantNumber == busLineVariantTrip.variant.variant })

            if (variant != nil) {
                let busStops = variant!.busStops!
                let busStopsCount = busStops.count
                var currentTime = busLineVariantTrip.trip.startTime

                for index in 0 ... busStopsCount - 1 {
                    let busStop = busStops[index]

                    if (index > 0) {
                        let lastBusStop = busStops[index - 1]
                        let exceptionTime = exceptionTimes.filter({ $0.tripId == busLineVariantTrip.trip.tripId }).find(predicate: { $0.locationNumber == lastBusStop })

                        if (exceptionTime != nil) {
                            currentTime = currentTime! + exceptionTime!.exceptionTime
                        } else {
                            let standardTimeIdentifier: String = [
                                    String(lastBusStop),
                                    String(busStop),
                                    String(busLineVariantTrip.trip.groupNumber)
                            ].joined(separator: ":")

                            let standardTime = standardTimesDictionary[standardTimeIdentifier]

                            if (standardTime != nil) {
                                currentTime = currentTime! + standardTime!.standardTime
                            }
                        }

                        if (index < busStopsCount - 1) {
                            let defaultWaitTime = defaultWaitTimes.filter({ $0.tripId == busLineVariantTrip.trip.tripId }).find(predicate: { $0.locationNumber == busStop })

                            if (defaultWaitTime != nil) {
                                currentTime = currentTime! + defaultWaitTime!.waitTime
                            } else {
                                let busWaitTime = busLineWaitTimes.filter({ $0.lineNumber == busLineVariantTrip.busLine.id }).filter({ $0.variantNumber == busLineVariantTrip.variant.variant }).filter({ $0.groupNumber == busLineVariantTrip.trip.groupNumber }).find(predicate: { $0.busStopOfTrip == index + 1 })
                                if (busWaitTime != nil) {
                                    currentTime = currentTime! + busWaitTime!.waitTime
                                } else {
                                    let busDefaultWaitTime = busDefaultWaitTimes.filter({ $0.locationNumber == busStop }).find(predicate: { $0.groupNumber == busLineVariantTrip.trip.groupNumber })
                                    if (busDefaultWaitTime != nil) {
                                        currentTime = currentTime! + busDefaultWaitTime!.waitTime
                                    }
                                }
                            }
                        }
                    }
                    stopTimes.append(BusTripBusStopTime(busStop: busStop, seconds: currentTime!))
                }
            }
        }

        stopTimes = stopTimes.sorted(by: { $0.seconds < $1.seconds })

        return stopTimes
    }
}
