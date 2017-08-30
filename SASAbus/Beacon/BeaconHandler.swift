import Foundation
import Permission
import CoreBluetooth

class BeaconHandler {

    static let instance = BeaconHandler()

    func start() {
        // TODO: Somehow check if bluetooth is enabled?
        
        guard Settings.areBeaconsEnabled() else {
            Log.error("Beacons are disabled, skipping")
            return
        }
        
        guard Settings.isIntroFinished() else {
            Log.error("Cannot start beacons because intro is not finished")
            return
        }
        
        guard Permission.locationAlways.status == .authorized else {
            Log.error("Cannot start beacons because location permission is missing")
            return
        }
        
        BusBeaconHandler.instance.startObserving()
    }

    func stop() {
        BusBeaconHandler.instance.stopObserving()
    }

    func save() {
        BusBeaconHandler.instance.saveState()
    }
}
