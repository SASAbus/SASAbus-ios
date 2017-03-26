import Foundation
import MapKit

class Config {
    
    static let mapLatitude: Double = 46.58
    static let mapLongitude: Double = 11.25
    static let mapDelta: Double = 0.8
    
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
    static let mapStandardZoom = 10
    static let mapHowOftenShouldIAskForMapDownload = 0

    // Parking
    static let parkingLotBaseUrl = ""

    // News
    static let newsApiUrl = ""

    // Bus beacon
    static let BUS_BEACON_UUID = "e923b236-f2b7-4a83-bb74-cfb7fa44cab8"
    static let BUS_BEACON_IDENTIFIER = "BUS"

    static let beaconSecondsInBus = 120
    static let beaconMinTripDistance = 100
    static let beaconLastSeenTreshold = 20


    // Bus stop beacon
    static let BUS_STOP_BEACON_UUID = "8f771fca-e25a-4a7f-af4e-1745a7be89ef"
    static let BUS_STOP_BEACON_IDENTIFIER = "BUS_STOP"

    static let busStopValiditySeconds = 10

    // Survey
    static let surveyApiUrl = ""
    static let surveyApiUsername = ""
    static let surveyApiPassword = ""
    static let surveyRecurringTimeDefault = 0

    // Bus stop
    static let busStopDistanceTreshold = 0.0
}
