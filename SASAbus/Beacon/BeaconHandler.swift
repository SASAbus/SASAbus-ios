//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class BeaconHandler {

    static let instance = BeaconHandler()

    func start() {
        BusBeaconHandler.instance.startObserving()
    }

    func stop() {
        BusBeaconHandler.instance.stopObserving()
    }

    func save() {
        BusBeaconHandler.instance.saveState()
    }
}