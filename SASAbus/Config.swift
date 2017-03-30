import Foundation
import MapKit

public class Config {

    static let mapLatitude: Double = 46.58
    static let mapLongitude: Double = 11.25
    static let mapDelta: Double = 0.5

    static let mapRegion: MKCoordinateRegion = {
        var region = MKCoordinateRegion()

        region.center.latitude = Config.mapLatitude
        region.center.longitude = Config.mapLongitude

        region.span.latitudeDelta = Config.mapDelta
        region.span.longitudeDelta = Config.mapDelta

        return region
    }()

    static let BUS_STOP_DETAILS_NO_DELAY: Int = 1 << 12
    static let BUS_STOP_DETAILS_OPERATION_RUNNING: Int = 1 << 11

    static let PLANNED_DATA_FOLDER = "data/"
    static let PLANNED_DATA_URL: String = "http://opensasa.info/SASAplandata/"

    // Router
    static let timeoutInterval = 0.0

    // Download
    static let downloadTimeoutIntervalForResource = 0.0
    static let downloadTimeoutIntervalForRequest = 0.0

    // Realtime
    static let realTimeDataUrl = ""

    // privacy
    static let privacyBaseUrl = ""

    // Map
    static let MAP_URL = "http://opensasa.info/files/maptiles/osm-tiles.zip"
    static let MAP_FOLDER = "map/"

    static let mapOnlineTiles = ""
    static let mapStandardLatitude = 46.58
    static let mapStandardLongitude = 11.25
    static let mapStandardZoom = 12
    static let mapHowOftenShouldIAskForMapDownload = 0

    // Bus beacon
    static let beaconSecondsInBus = 120
    static let beaconMinTripDistance = 100
    static let beaconLastSeenThreshold = 20

    // Bus stop beacon
    static let busStopValiditySeconds = 10

    // Survey
    static let surveyApiUrl = ""
    static let surveyApiUsername = ""
    static let surveyApiPassword = ""
    static let surveyRecurringTimeDefault = 0

    // Bus stop
    static let busStopDistanceThreshold = 0.0
}
