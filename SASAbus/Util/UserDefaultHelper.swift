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

    //all userdefault keys here
    static let MAP_DOWNLOADED_DONE_KEY: String = "MAP_DOWNLOADED_DONE_KEY"
    static let DATA_DOWNLOADED_DONE_KEY: String = "DATA_DOWNLOADED_DONE_KEY"
    static let LAST_SURVEY_KEY: String = "LAST_SURVEY_KEY"
    static let SURVEY_CYCLE_KEY: String = "SURVEY_CYCLE_KEY"
    static let BUS_STATION_FAVORITES_KEY: String = "BUS_STATION_FAVORITES_KEY"
    static let ASK_FOR_MAPS_DOWNLOAD_KEY: String = "ASK_FOR_MAPS_DOWNLOAD_KEY"
    static let ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY: String = "ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY"
    static let PRIVACY_HTML_KEY: String = "PRIVACY_HTML_KEY"
    static let BEACON_STATION_DETECTION_KEY: String = "BEACON_STATION_DETECTION_KEY"
    static let BEACON_CURRENT_BUS_STOP_KEY: String = "BEACON_CURRENT_BUS_STATION_KEY"
    static let BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY: String = "BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY"

    init() {
        //Init user defaults
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults[UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY] = true as AnyObject?
        appDefaults[UserDefaultHelper.BEACON_STATION_DETECTION_KEY] = true as AnyObject?
        appDefaults[UserDefaultHelper.SURVEY_CYCLE_KEY] = 604800 as AnyObject?
        appDefaults[UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY] = 0 as AnyObject?
        UserDefaults.standard.register(defaults: appDefaults)
        UserDefaults.standard.synchronize()
    }

    func getUserDefaults() -> UserDefaults {
        return UserDefaults.standard
    }

    func addFavoriteBusStation(_ busStation: BusStationItem) -> Bool {
        var success = false
        var favoriteBusStations = self.getFavoriteBusStations()

        if favoriteBusStations.find({ $0.name == busStation.name }) == nil {
            favoriteBusStations.append(busStation)
            self.getUserDefaults().set(NSKeyedArchiver.archivedData(withRootObject: favoriteBusStations),
                    forKey: UserDefaultHelper.BUS_STATION_FAVORITES_KEY)
            self.getUserDefaults().synchronize()

            success = true
        }
        return success
    }

    func removeFavoriteBusStation(_ busStation: BusStationItem) -> Bool {
        var success = false
        var favoriteBusStations = self.getFavoriteBusStations()
        if let index = favoriteBusStations.index(where: { $0.name == busStation.name }) {
            favoriteBusStations.remove(at: index)
            self.getUserDefaults().set(NSKeyedArchiver.archivedData(withRootObject: favoriteBusStations),
                    forKey: UserDefaultHelper.BUS_STATION_FAVORITES_KEY)
            self.getUserDefaults().synchronize()
            success = true
        }
        return success
    }

    func getFavoriteBusStations() -> [BusStationItem] {
        var favoriteBusStations: [BusStationItem] = []
        let data = self.getUserDefaults().object(forKey: UserDefaultHelper.BUS_STATION_FAVORITES_KEY)
        if data != nil {
            favoriteBusStations = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [BusStationItem]
        }
        favoriteBusStations.sort(by: { $0.getDescription()
                .localizedCaseInsensitiveCompare($1.getDescription()) == ComparisonResult.orderedAscending })
        return favoriteBusStations
    }

    func setDataDownloadStatus(_ done: Bool) {
        self.getUserDefaults().set(done, forKey: UserDefaultHelper.DATA_DOWNLOADED_DONE_KEY)
        self.getUserDefaults().synchronize()
    }

    func getDataDownloadStatus() -> Bool {
        var dataDownloadStatus = false
        if self.getUserDefaults().object(forKey: UserDefaultHelper.DATA_DOWNLOADED_DONE_KEY) != nil {
            dataDownloadStatus = self.getUserDefaults().bool(forKey: UserDefaultHelper.DATA_DOWNLOADED_DONE_KEY)
        }
        return dataDownloadStatus
    }

    func setMapDownloadStatus(_ done: Bool) {
        self.getUserDefaults().set(done, forKey: UserDefaultHelper.MAP_DOWNLOADED_DONE_KEY)
        self.getUserDefaults().synchronize()
    }

    func getMapDownloadStatus() -> Bool {
        var mapDownloadStatus = false
        if self.getUserDefaults().object(forKey: UserDefaultHelper.MAP_DOWNLOADED_DONE_KEY) != nil {
            mapDownloadStatus = self.getUserDefaults().bool(forKey: UserDefaultHelper.MAP_DOWNLOADED_DONE_KEY)
        }
        return mapDownloadStatus
    }

    func setLastSurveyTimeStamp(_ surveyTimeStamp: Int) {
        self.getUserDefaults().set(surveyTimeStamp, forKey: UserDefaultHelper.LAST_SURVEY_KEY)
        self.getUserDefaults().synchronize()
    }

    func getLastSurveyTimeStamp() -> Int? {
        var lastSurveyTimeStamp: Int? = nil
        if self.getUserDefaults().object(forKey: UserDefaultHelper.LAST_SURVEY_KEY) != nil {
            lastSurveyTimeStamp = self.getUserDefaults().integer(forKey: UserDefaultHelper.LAST_SURVEY_KEY)
        }
        return lastSurveyTimeStamp
    }

    func getSurveyCycle() -> Int? {
        var surveyCycle: Int? = Config.surveyRecurringTimeDefault
        if self.getUserDefaults().object(forKey: UserDefaultHelper.SURVEY_CYCLE_KEY) != nil {
            surveyCycle = self.getUserDefaults().integer(forKey: UserDefaultHelper.SURVEY_CYCLE_KEY)
        }
        return surveyCycle
    }

    func isBeaconStationDetectionEnabled() -> Bool {
        var beaconStationDetectionEnabled: Bool = true
        if self.getUserDefaults().object(forKey: UserDefaultHelper.BEACON_STATION_DETECTION_KEY) != nil {
            beaconStationDetectionEnabled = self.getUserDefaults().bool(forKey: UserDefaultHelper.BEACON_STATION_DETECTION_KEY)
        }
        return beaconStationDetectionEnabled
    }

    func shouldAskForMapDownload() -> Bool {
        var askForMapDownload: Bool = true
        if self.getUserDefaults().object(forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY) != nil {
            askForMapDownload = self.getUserDefaults().bool(forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY)
        }
        return askForMapDownload
    }

    func setAskForMapDownload(_ value: Bool) {
        self.getUserDefaults().set(value, forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY)
        self.getUserDefaults().synchronize()
    }

    func getAskedForDownloadsNoCount() -> Int {
        var askedForDownloadsNoCount: Int = 0
        if self.getUserDefaults().object(forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY) != nil {
            askedForDownloadsNoCount = self.getUserDefaults().integer(forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY)
        }
        return askedForDownloadsNoCount
    }

    func incrementAskedForDownloadsNoCount() {
        let askedForDownloadsNoCount = self.getAskedForDownloadsNoCount() + 1
        self.getUserDefaults().set(askedForDownloadsNoCount, forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY)
        self.getUserDefaults().synchronize()
    }

    func setPrivacyHtml(_ value: String) {
        self.getUserDefaults().setValue(value, forKey: UserDefaultHelper.PRIVACY_HTML_KEY)
        self.getUserDefaults().synchronize()
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
