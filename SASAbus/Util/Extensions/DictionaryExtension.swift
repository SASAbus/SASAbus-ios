//
// Created by Alex Lardschneider on 05/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

extension Dictionary where Key == Int, Value == BusBeacon {

    static func +=<Int, BusBeacon>(left: inout [Int : BusBeacon], right: [Int : BusBeacon]) {
        for (k, v) in right {
            left[k] = v
        }
    }
}

extension Dictionary {
    public func map<T, U>(transform: (Key, Value) -> (T, U)) -> [T : U] {
        var result: [T : U] = [:]
        for (key, value) in self {
            let (transformedKey, transformedValue) = transform(key, value)
            result[transformedKey] = transformedValue
        }
        return result
    }

    public func map<T, U>(transform: (Key, Value) throws -> (T, U)) rethrows -> [T : U] {
        var result: [T : U] = [:]
        for (key, value) in self {
            let (transformedKey, transformedValue) = try transform(key, value)
            result[transformedKey] = transformedValue
        }
        return result
    }
}
