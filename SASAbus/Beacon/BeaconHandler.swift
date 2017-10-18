import Foundation
import Permission
import CoreBluetooth

class BeaconHandler {

    static let instance = BeaconHandler()

    func start() {
        Log.warning("BEACONS: Start")
        
        // TODO: Somehow check if bluetooth is enabled?
        
        guard Settings.areBeaconsEnabled() else {
            Log.error("BEACONS: Disabled in settings")
            return
        }
        
        guard Settings.isIntroFinished() else {
            Log.error("BEACONS: Intro is not finished")
            return
        }
        
        guard Permission.locationAlways.status == .authorized else {
            Log.error("BEACONS: Location permission is missing")
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
