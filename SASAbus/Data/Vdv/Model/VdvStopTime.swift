//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

/**
 * Represents the stop time of a bus at a specific stop.
 *
 * @author David Dejori
 */
class VdvStopTime: Hashable {

    var id: Int
    var stop: Int

    init(id: Int, stop: Int) {
        self.id = id
        self.stop = stop
    }

    var hashValue: Int {
        var result = id
        result = 31 * result + stop
        return result
    }


    public static func ==(lhs: VdvStopTime, rhs: VdvStopTime) -> Bool {
        return lhs.id == rhs.id && lhs.stop == rhs.stop
    }
}