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


    static func load() -> Observable<Float> {
        return Observable.create { observer in
            do {
                try loadBlocking(observer)
            } catch let error {
                observer.on(.error(error))
            }

            return Disposables.create()
        }
    }

    static func loadBlocking(_ observer: AnyObserver<Float>?) throws {
        defer {
            isLoading = false
        }

        if Thread.isMainThread {
            fatalError("Loading planned data on main thread is prohibited!")
        }

        if !PlannedData.planDataExists() {
            BeaconHandler.instance.stop()
            Log.error("Planned data does not exist, skipping loading")

            throw VdvError.plannedDataNotFound
        }

        if isLoaded {
            Log.warning("Planned data already loaded")
            return
        }

        if isLoading {
            Log.warning("Already loading data...")
            blockTillLoaded()
            return
        }

        isLoading = true

        do {
            let time = -Date().millis()

            var json = try IOUtils.readFileAsJson(path: getPlannedDataFile())

            observer?.on(.next(0.94))

            VdvCalendar.loadCalendar(jCalendar: json["calendar"].arrayValue)

            observer?.on(.next(0.95))

            VdvPaths.loadPaths(jPaths: json["paths"].arrayValue)

            observer?.on(.next(0.96))

            try VdvTrips.loadTripsOfToday()

            observer?.on(.next(0.97))

            VdvTravelTimes.loadTravelTimes(jIntervals: json["travel_times"].arrayValue)

            observer?.on(.next(0.98))

            VdvBusStopBreaks.loadBreaks(jStopTimes: json["bus_stop_stop_times"].arrayValue)

            observer?.on(.next(0.99))

            VdvTripStopTimes.loadStopTimes(jHaltTimes: json["trip_stop_times"].arrayValue)

            isValid = true

            Log.info("Loaded planned data in \(time + Date().millis()) ms")
        } catch VdvError.vdvError(let message) {
            BeaconHandler.instance.stop()
            Log.error("Cannot load planned data: \(message)")

            throw VdvError.vdvError(message: message)
        } catch VdvError.jsonError {
            // If this happens, the json plan data most likely is in an invalid format
            // because it got corrupted somehow, or someone modified it on purpose.
            // We should reschedule a new plan data download if this happens.
            BeaconHandler.instance.stop()
            PlannedData.setUpdateAvailable(true)

            throw VdvError.jsonError
        } catch let error {
            Log.error(error)
        }

        observer?.on(.next(0.100))

        Log.error("Finished vdv data loading")

        isLoaded = true
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
        return IOUtils.dataDir().appendingPathComponent("/planned_data.json")
    }

    static func getTripsDataFile(day: Int) -> URL {
        return IOUtils.dataDir().appendingPathComponent(String.init(format: "/trips_%d.json", day))
    }
}

enum VdvError: Error {
    case vdvError(message: String)
    case jsonError
    case plannedDataNotFound
    case mainThread
}
