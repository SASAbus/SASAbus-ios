import Foundation
import Firebase

public struct Endpoint {

    static let REALTIME = "realtime"
    static let REALTIME_VEHICLE = "realtime/vehicle/" // {id}
    static let REALTIME_DELAYS = "realtime/delays"
    static let REALTIME_LINE = "realtime/line/" // {id}
    static let REALTIME_TRIP = "realtime/trip/{id}"

    static let LINES_ALL = "lines"
    static let LINES_HYDROGEN = "realtime/h2"
    static let LINES_FILTER = "lines/line/" // {lines}

    static let NEWS = "news"
    static let PARKING = "parking"
    static let PATHS = "paths/" // {id}
    static let ROUTE = "route/from/{from}/to/{to}/on/{date}/at/{time}/walk/{walk}/results/{results}"
    static let TOKEN = "gcm/tokens/{token}"

    static let USER_LOGIN = "auth/login"
    static let USER_LOGIN_GOOGLE = "auth/login/google"
    static let USER_REGISTER = "auth/register"
    static let USER_LOGOUT = "auth/logout"
    static let USER_LOGOUT_ALL = "auth/logout/all"
    static let USER_DELETE = "auth/delete"
    static let USER_VERIFY = "auth/verify/{email}/{token}"
    static let USER_CHANGE_PASSWORD = "auth/password/change"

    static let ECO_POINTS_BADGES = "eco/badges"
    static let ECO_POINTS_BADGES_NEXT = "eco/badges/next"
    static let ECO_POINTS_BADGES_EARNED = "eco/badges/earned"
    static let ECO_POINTS_BADGES_SEND = "eco/badges/earned/" // {id}
    static let ECO_POINTS_LEADERBOARD = "eco/leaderboard/page/" // {page}
    static let ECO_POINTS_PROFILE = "eco/profile"
    static let ECO_POINTS_PROFILE_PICTURE_DEFAULT = "eco/profile/default"
    static let ECO_POINTS_PROFILE_PICTURE_CUSTOM = "eco/profile/custom"

    static let ECO_POINTS_PROFILE_PICTURE_USER = "assets/images/profile_pictures/"

    static let REPORT = "ios/report"
    static let SURVEY = "survey"

    static let DISRUPTIONS = "disruptions"
    static let DISRUPTIONS_LINES = "disruptions/line/{lines}"

    static let TRIPS = "trips/vehicle/{id}"
    static let TRIPS_VEHICLE = "vehicles/id/{id}/trips"

    static let VALIDITY_DATA = "validity/data/{date}"
    static let VALIDITY_TIMETABLES = "validity/timetables/{date}"

    static let CLOUD_TRIPS = "sync/trips"
    static let CLOUD_TRIPS_DELETE = "sync/trips/{hash}"
    static let CLOUD_PLANNED_TRIPS = "sync/planned_trips"
    static let CLOUD_PLANNED_TRIPS_DELETE = "sync/planned_trips/{hash}"

    static let MAP_TILES = "map/coordinates/%d/%d/%d/line/%d/variant/%d"
    static let MAP_TILES_ALL = "map/coordinates/%d/%d/%d"


    // ========================================== REMOTE CONFIG ENDPOINTS ==============================================

    static var apiUrl: String {
        return RemoteConfig.remoteConfig()[Config.REMOTE_CONFIG_HOST_URL].stringValue!
    }

    static var realtimeApiUrl: String {
        return RemoteConfig.remoteConfig()[Config.REMOTE_CONFIG_HOST_URL_REALTIME].stringValue!
    }

    static var dataApiUrl: String {
        return RemoteConfig.remoteConfig()[Config.REMOTE_CONFIG_HOST_URL_DATA].stringValue!
    }

    static var reportsApiUrl: String {
        return RemoteConfig.remoteConfig()[Config.REMOTE_CONFIG_HOST_URL_REPORTS].stringValue!
    }

    static var telemetryApiUrl: String {
        return RemoteConfig.remoteConfig()[Config.REMOTE_CONFIG_HOST_URL_TELEMETRY].stringValue!
    }

    static var databaseApiUrl: String {
        return RemoteConfig.remoteConfig()[Config.REMOTE_CONFIG_HOST_URL_DATABASE].stringValue!
    }
}
