//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

class VdvHandler {

    static var isLoaded = false
    static var isLoading = false
    static var isValid = false

    static func load() -> Observable<Any> {
        return Observable.create { observer in
            defer {
                isLoading = false
            }

            if Thread.isMainThread {
                fatalError("Loading planned data on main thread is prohibited!")
            }

            if !PlannedData.planDataExists() {
                BeaconHandler.instance.stop()
                Log.error("Planned data does not exist, skipping loading")
                return Disposables.create()
            }

            if isLoaded {
                Log.warning("Planned data already loaded")
                return Disposables.create()
            }

            if isLoading {
                Log.warning("Already loading data...")
                blockTillLoaded()
                return Disposables.create()
            }

            isLoading = true

            do {
                let time = -Date().millis()

                var json = try IOUtils.readFileAsJson(path: getPlannedDataFile())

                observer.on(.next(94))

                VdvCalendar.loadCalendar(jCalendar: json["calendar"].arrayValue)

                observer.on(.next(95))

                VdvPaths.loadPaths(jPaths: json["paths"].arrayValue)

                observer.on(.next(96))

                try VdvTrips.loadTrips(jDepartures: json["trips"].arrayValue, dayId: VdvCalendar.today().id)

                observer.on(.next(97))

                VdvIntervals.loadIntervals(jIntervals: json["travel_times"].arrayValue)

                observer.on(.next(98))

                VdvBusStopBreaks.loadBreaks(jStopTimes: json["bus_stop_stop_times"].arrayValue)

                observer.on(.next(99))

                VdvTripBreaks.loadBreaks(jHaltTimes: json["trip_stop_times"].arrayValue)

                isValid = true

                Log.info("Loaded planned data in \(time + Date().millis()) ms")
            } catch VdvError.vdvError(let message) {
                BeaconHandler.instance.stop()
                Log.error("Cannot load planned data: \(message)")
                return Disposables.create()
            } catch VdvError.jsonError {

                // If this happens, the json plan data most likely is in an invalid format
                // because it got corrupted somehow, or someone modified it on purpose.
                // We should reschedule a new plan data download if this happens.
                BeaconHandler.instance.stop()
                PlannedData.setUpdateAvailable(true)

                observer.on(.error(VdvError.jsonError))
                return Disposables.create()
            } catch let error {
                Log.error(error)
            }

            isLoaded = true

            observer.on(.next(100))

            Log.error("Finished vdv data loading")

            return Disposables.create()
        }
    }

    static func blockTillLoaded(verifyUiThread: Bool = true) {
        if verifyUiThread {
            if Thread.isMainThread {
                fatalError("blockTillLoaded() called on main thread")
            }
        }

        if !isLoaded {
            Log.info("Data not loaded yet, waiting...")

            while !isLoaded {
                usleep(100000)
            }

            Log.info("Data finished loading")
        }
    }

    static func reset() {
        Log.error("Reset plan data")

        isLoaded = false
        isLoading = false
        isValid = false
    }

    static func getPlannedDataFile() -> URL {
        return IOUtils.dataDir().appendingPathComponent("/planned-data.json")
    }
}

enum VdvError: Error {
    case vdvError(message: String)
    case jsonError
    case mainThread
}
