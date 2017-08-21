import Foundation
import CoreLocation

class BusStopBeaconHandler: NSObject, CLLocationManagerDelegate {

    let UUID_STRING = "8f771fca-e25a-4a7f-af4e-1745a7be89ef"
    let IDENTIFIER = "BUS_STOP"

    private let locationManager = CLLocationManager()
    private var region: CLBeaconRegion!
    private var regions: [String : CLBeaconRegion] = [:]
    private var didEnterRegionDate: NSDate?
    private var didExitRegionDate: NSDate?

    override init() {
        super.init()

        self.locationManager.delegate = self

        self.region = CLBeaconRegion(proximityUUID: UUID(uuidString: UUID_STRING)!, identifier: IDENTIFIER)
        self.region.notifyEntryStateOnDisplay = true
        self.region.notifyOnEntry = true
        self.region.notifyOnExit = true
    }

    func startObserving() {
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }

        Log.warning("startObserving() BUS_STOP")

        locationManager.startMonitoring(for: self.region)
        locationManager.startRangingBeacons(in: self.region)
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            Log.info("Beacon #\(beacon.major), distance: \(beacon.proximity.rawValue)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let now = NSDate()

        if didEnterRegionDate == nil || now.timeIntervalSince1970 - (didEnterRegionDate?.timeIntervalSince1970)! > 2 {
            didEnterRegionDate = now

            Log.warning("didEnterRegion() BUS_STOP")
            locationManager.startRangingBeacons(in: self.region)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let now = NSDate()

        if didExitRegionDate == nil || now.timeIntervalSince1970 - (didExitRegionDate?.timeIntervalSince1970)! > 2 {
            didExitRegionDate = now

            Log.warning("didExitRegion() BUS_STOP")
            locationManager.stopRangingBeacons(in: self.region)
        }
    }
}
