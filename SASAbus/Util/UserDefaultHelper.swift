//
// UserDefaultHelper.swift
// SASAbus
//
// Copyright (C) 2011-2015 Raiffeisen Online GmbH (Norman Marmsoler, Jürgen Sprenger, Aaron Falk) <info@raiffeisen.it>
//
// This file is part of SASAbus.
//
// SASAbus is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SASAbus is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SASAbus.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class UserDefaultHelper {

    static let instance = UserDefaultHelper()

    static let PRIVACY_HTML_KEY: String = "PRIVACY_HTML_KEY"
    static let BEACON_STATION_DETECTION_KEY: String = "BEACON_STATION_DETECTION_KEY"
    static let BEACON_CURRENT_BUS_STOP_KEY: String = "BEACON_CURRENT_BUS_STATION_KEY"
    static let BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY: String = "BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY"

    init() {
        var appDefaults: [String: AnyObject] = [:]

        appDefaults[UserDefaultHelper.BEACON_STATION_DETECTION_KEY] = true as AnyObject?

        UserDefaults.standard.register(defaults: appDefaults)
        UserDefaults.standard.synchronize()
    }

    func getUserDefaults() -> UserDefaults {
        return UserDefaults.standard
    }


    func isBeaconStationDetectionEnabled() -> Bool {
        var beaconStationDetectionEnabled: Bool = true
        if self.getUserDefaults().object(forKey: UserDefaultHelper.BEACON_STATION_DETECTION_KEY) != nil {
            beaconStationDetectionEnabled = self.getUserDefaults().bool(forKey: UserDefaultHelper.BEACON_STATION_DETECTION_KEY)
        }
        return beaconStationDetectionEnabled
    }

    func getPrivacyHtml() -> String {
        var privacyHtml: String = ""
        if self.getUserDefaults().object(forKey: UserDefaultHelper.PRIVACY_HTML_KEY) != nil {
            privacyHtml = self.getUserDefaults().string(forKey: UserDefaultHelper.PRIVACY_HTML_KEY)!
        }
        return privacyHtml
    }

    func getCurrentBusStop() -> Int? {
        var currentBusStop: Int? = nil
        var currentBusStopTimeStamp: Int? = nil
        if self.getUserDefaults().object(forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY) != nil {
            currentBusStop = self.getUserDefaults().integer(forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY)
        }

        if self.getUserDefaults().object(forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY) != nil {
            currentBusStopTimeStamp = self.getUserDefaults().integer(forKey:
            UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY)
        }

        if currentBusStopTimeStamp != nil &&
                   currentBusStop != nil {

            let nowTimeStamp = Int(Date().timeIntervalSince1970)
            let difference = nowTimeStamp - currentBusStopTimeStamp!

            if difference < Config.busStopValiditySeconds {
                return currentBusStop
            } else {
                UserDefaultHelper.instance.setCurrentBusStopId(nil)
                return nil
            }
        } else {
            return nil
        }

    }

    func setCurrentBusStopId(_ value: Int? = nil) {
        if value == nil {
            self.getUserDefaults().removeObject(forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY)
            self.getUserDefaults().removeObject(forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY)
        } else {
            self.getUserDefaults().setValue(value, forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY)
            self.getUserDefaults().setValue(Int(Date().timeIntervalSince1970), forKey:

            UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY)
        }

        self.getUserDefaults().synchronize()
    }
}
