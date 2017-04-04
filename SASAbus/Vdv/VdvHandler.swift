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

    private static let asyncGroup = DispatchGroup()

    static func load() -> Observable<Any> {
        return Observable.create { observer in
            if Thread.isMainThread {
                fatalError()
            }

            // JodaTimeAndroid.init(context)

            if !PlannedData.planDataExists() {
                BeaconHandler.get().stop()
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
                var time = -Date().millis()

                var rawData = IOUtils.readFileAsString(path: getPlannedDataFile())
                var jsonObject = JSON(rawData)

                observer.on(.next(94))

                VdvCalendar.loadCalendar(jCalendar: jsonObject["calendar"].arrayValue)

                observer.on(.next(95))

                VdvPaths.loadPaths(jPaths: jsonObject["paths"].arrayValue)

                observer.on(.next(96))

                try VdvTrips.loadTrips(jDepartures: jsonObject["trips"].arrayValue, dayId: VdvCalendar.today().id)

                observer.on(.next(97))

                VdvIntervals.loadIntervals(jIntervals: jsonObject["travel_times"].arrayValue)

                observer.on(.next(98))

                VdvBusStopBreaks.loadBreaks(jStopTimes: jsonObject["bus_stop_stop_times"].arrayValue)

                observer.on(.next(99))

                VdvTripBreaks.loadBreaks(jHaltTimes: jsonObject["trip_stop_times"].arrayValue)

                isValid = true

                Log.info("Loaded planned data in %d ms", time + Date().millis())
            } catch VdvError.vdvError(let message) {
                BeaconHandler.get().stop()
                Log.error("Cannot load planned data: \(message)")
                return Disposables.create()
            } catch VdvError.jsonError {

                // If this happens, the json plan data most likely is in an invalid format
                // because it got corrupted somehow, or someone modified it on purpose.
                // We should reschedule a new plan data download if this happens.
                BeaconHandler.get().stop()
                PlannedData.setUpdateAvailable(true)

                observer.on(.error(VdvError.jsonError))
                return Disposables.create()
            } catch let error {
                Log.error(error)
            }

            isLoaded = true
            isLoading = false

            // Awake sleeping threads waiting for plan data loading to complete
            asyncGroup.leave()

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
                asyncGroup.enter()
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
