import Foundation
import MapKit

public class Config {

    static let BUS_STOP_DETAILS_NO_DELAY: Int = 1 << 12
    static let BUS_STOP_DETAILS_OPERATION_RUNNING: Int = 1 << 11

    // Bus stop beacon
    static let busStopValiditySeconds = 10

    // Survey
    static let surveyApiUrl = ""
    static let surveyApiUsername = ""
    static let surveyApiPassword = ""
    static let surveyRecurringTimeDefault = 0


    static let DELIMITER = ", "

    static let DIESEL_PRICE: Float = 1.48


    // ====================================== REMOTE CONFIG ========================================

    static let REMOTE_CONFIG_HOST_URL = "host_api"
    static let REMOTE_CONFIG_HOST_URL_DATA = "host_api_data"
    static let REMOTE_CONFIG_HOST_URL_REPORTS = "host_api_reports"
    static let REMOTE_CONFIG_HOST_URL_TELEMETRY = "host_api_telemetry"
    static let REMOTE_CONFIG_HOST_URL_DATABASE = "host_api_database"
    static let REMOTE_CONFIG_HOST_URL_REALTIME = "realtime_api_url"
}
