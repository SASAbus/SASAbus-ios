import Foundation
import CoreLocation
import MapKit

class MapUtils {

    static let PREF_MAP_TYPE = "pref_map_type"

    static let PREF_TILE_OVERLAY_ENABLED = "pref_tile_overlay_enabled"
    static let PREF_TILE_OVERLAY_ENABLED_ALL = "pref_tile_overlay_enabled_all"


    static func getMapType() -> MKMapType? {
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
}
