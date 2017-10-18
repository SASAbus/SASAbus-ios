import Foundation
import CoreLocation
import MapKit

class MapUtils {

    static let PREF_MAP_TYPE = "pref_map_type"
    static let PREF_DEFAULT_MAP_POSITION = "pref_default_map_position"

    static let PREF_TILE_OVERLAY_ENABLED = "pref_tile_overlay_enabled"
    static let PREF_TILE_OVERLAY_ENABLED_ALL = "pref_tile_overlay_enabled_all"

    static let PREF_AUTO_REFRESH_ENABLED = "pref_map_auto_refresh_enabled"
    static let PREF_AUTO_REFRESH_INTERVAL = "pref_map_auto_refresh_interval"


    static func getMapType() -> MKMapType {
        let userDefaults = UserDefaults.standard
        let mapType = userDefaults.string(forKey: PREF_MAP_TYPE) ?? "standard"

        switch mapType {
        case "standard":
            return MKMapType.standard
        case "hybrid":
            return MKMapType.hybrid
        case "satellite":
            return MKMapType.satellite
        default:
            Log.error("Invalid map type: \(mapType), returning default")
            return MKMapType.standard
        }
    }


    static func mapOverlaysEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_TILE_OVERLAY_ENABLED)
    }

    static func allMapOverlaysEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_TILE_OVERLAY_ENABLED_ALL)
    }


    static func isAutoRefreshEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: PREF_AUTO_REFRESH_ENABLED)
    }

    static func getAutoRefreshInterval() -> TimeInterval {
        return TimeInterval(UserDefaults.standard.integer(forKey: PREF_AUTO_REFRESH_INTERVAL))
    }


    static func getRegion() -> MKCoordinateRegion {
        let position = UserDefaults.standard.integer(forKey: PREF_DEFAULT_MAP_POSITION)

        switch position {
        case 2:
            return cameraBz()
        case 3:
            return cameraMe()
        default:
            return defaultCamera()
        }
    }
}

extension MapUtils {

    static func defaultCamera() -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: 46.58, longitude: 11.25)
        return MKCoordinateRegionMakeWithDistance(center, 35000, 35000)
    }

    fileprivate static func cameraBz() -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: 46.46, longitude: 11.33)
        return MKCoordinateRegionMakeWithDistance(center, 16000, 16000)
    }

    fileprivate static func cameraMe() -> MKCoordinateRegion {
        let center = CLLocationCoordinate2D(latitude: 46.6532, longitude: 11.1606)
        return MKCoordinateRegionMakeWithDistance(center, 20000, 20000)
    }
}
