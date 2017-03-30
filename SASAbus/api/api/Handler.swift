import Foundation

class Handler {

    static var loaded: Bool = false

    static func load() {
        if loaded {
            return
        }

        Handler.loaded = true

        if Thread.isMainThread {
            Log.warning("Warning: Handler.load() called from main thread")
        }

        Log.info("Loading JSON data from files")

        let baseUrl = IOUtils.dataDir()

        CompanyCalendar.loadCalendar(baseDir: baseUrl)
        Paths.loadPaths(baseDir: baseUrl)
        Trips.loadTrips(baseDir: baseUrl)
        Intervals.loadIntervals(baseDir: baseUrl)
        StopTimes.loadStopTimes(baseDir: baseUrl)
        HaltTimes.loadHaltTimes(baseDir: baseUrl)

        Log.info("Loaded JSON data from files")
    }
}
