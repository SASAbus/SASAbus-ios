//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import CoreLocation
import EVReflection

class AbsBeacon: EVObject {

    var id: Int

    init(id: Int) {
        self.id = id

        super.init()

        seen()
    }

    public required init() {
        fatalError()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }


    var startDate = Date()

    var seenSeconds: Int64 = 0
    var lastSeen: Int64 = 0

    var distance: CLProximity = .unknown

    func seen() {
        let millis = Date().millis()

        seenSeconds = (millis - startDate.millis()) / 1000
        lastSeen = millis
    }
}
