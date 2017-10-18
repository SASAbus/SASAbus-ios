//
// Created by Alex Lardschneider on 05/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

extension Date {

    func millis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }

    func seconds() -> Int {
        return Int(timeIntervalSince1970)
    }
}
