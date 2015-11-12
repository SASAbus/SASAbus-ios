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
    static let MAP_DOWNLOADED_DONE_KEY:String = "MAP_DOWNLOADED_DONE_KEY"
    static let DATA_DOWNLOADED_DONE_KEY:String = "DATA_DOWNLOADED_DONE_KEY"
    static let LAST_SURVEY_KEY:String = "LAST_SURVEY_KEY"
    static let SURVEY_CYCLE_KEY:String = "SURVEY_CYCLE_KEY"
    static let BUS_STATION_FAVORITES_KEY:String = "BUS_STATION_FAVORITES_KEY"
    static let ASK_FOR_MAPS_DOWNLOAD_KEY:String = "ASK_FOR_MAPS_DOWNLOAD_KEY"
    static let ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY:String = "ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY"
    static let PRIVACY_HTML_KEY:String = "PRIVACY_HTML_KEY"
    static let BEACON_STATION_DETECTION_KEY:String = "BEACON_STATION_DETECTION_KEY"
    static let BEACON_CURRENT_BUS_STOP_KEY:String = "BEACON_CURRENT_BUS_STATION_KEY"
    static let BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY:String = "BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY"
    
    init() {
        //Init user defaults
        var appDefaults = Dictionary<String, AnyObject>()
        appDefaults[UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY] = true
        appDefaults[UserDefaultHelper.BEACON_STATION_DETECTION_KEY] = true
        appDefaults[UserDefaultHelper.SURVEY_CYCLE_KEY] = 604800
        appDefaults[UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY] = 0
        NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getUserDefaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults();
    }
    
    func addFavoriteBusStation(busStation: BusStationItem) -> Bool {
        var success = false
        var favoriteBusStations = self.getFavoriteBusStations()
        if favoriteBusStations.find({$0.getName() == busStation.getName()}) == nil {
            favoriteBusStations.append(busStation)
            self.getUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(favoriteBusStations), forKey: UserDefaultHelper.BUS_STATION_FAVORITES_KEY)
            self.getUserDefaults().synchronize()
            success = true
        }
        return success
    }
    
    func removeFavoriteBusStation(busStation: BusStationItem) -> Bool {
        var success = false
        var favoriteBusStations = self.getFavoriteBusStations()
        if let index = favoriteBusStations.indexOf({$0.getName() == busStation.getName()}) {
            favoriteBusStations.removeAtIndex(index)
            self.getUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(favoriteBusStations), forKey: UserDefaultHelper.BUS_STATION_FAVORITES_KEY)
            self.getUserDefaults().synchronize()
            success = true
        }
        return success
    }
    
    func getFavoriteBusStations() -> [BusStationItem] {
        var favoriteBusStations: [BusStationItem] = []
        let data = self.getUserDefaults().objectForKey(UserDefaultHelper.BUS_STATION_FAVORITES_KEY)
        if data != nil {
            favoriteBusStations = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as! [BusStationItem]
        }
        favoriteBusStations.sortInPlace({$0.getDescription().localizedCaseInsensitiveCompare($1.getDescription()) == NSComparisonResult.OrderedAscending})
        return favoriteBusStations
    }
    
    func setDataDownloadStatus(done:Bool) {
        self.getUserDefaults().setBool(done, forKey: UserDefaultHelper.DATA_DOWNLOADED_DONE_KEY)
        self.getUserDefaults().synchronize()
    }
    
    func getDataDownloadStatus() -> Bool {
        var dataDownloadStatus = false
        if self.getUserDefaults().objectForKey(UserDefaultHelper.DATA_DOWNLOADED_DONE_KEY) != nil {
            dataDownloadStatus = self.getUserDefaults().boolForKey(UserDefaultHelper.DATA_DOWNLOADED_DONE_KEY)
        }
        return dataDownloadStatus
    }
    
    func setMapDownloadStatus(done:Bool) {
        self.getUserDefaults().setBool(done, forKey: UserDefaultHelper.MAP_DOWNLOADED_DONE_KEY)
        self.getUserDefaults().synchronize()
    }
    
    func getMapDownloadStatus() -> Bool {
        var mapDownloadStatus = false
        if self.getUserDefaults().objectForKey(UserDefaultHelper.MAP_DOWNLOADED_DONE_KEY) != nil {
            mapDownloadStatus = self.getUserDefaults().boolForKey(UserDefaultHelper.MAP_DOWNLOADED_DONE_KEY)
        }
        return mapDownloadStatus
    }
    
    func setLastSurveyTimeStamp(surveyTimeStamp:Int) {
        self.getUserDefaults().setInteger(surveyTimeStamp, forKey: UserDefaultHelper.LAST_SURVEY_KEY)
        self.getUserDefaults().synchronize()
    }
    
    func getLastSurveyTimeStamp() -> Int? {
        var lastSurveyTimeStamp:Int? = nil
        if self.getUserDefaults().objectForKey(UserDefaultHelper.LAST_SURVEY_KEY) != nil {
            lastSurveyTimeStamp = self.getUserDefaults().integerForKey(UserDefaultHelper.LAST_SURVEY_KEY)
        }
        return lastSurveyTimeStamp
    }
    
    func getSurveyCycle() -> Int? {
        var surveyCycle:Int? = Configuration.surveyRecurringTimeDefault
        if self.getUserDefaults().objectForKey(UserDefaultHelper.SURVEY_CYCLE_KEY) != nil {
            surveyCycle = self.getUserDefaults().integerForKey(UserDefaultHelper.SURVEY_CYCLE_KEY)
        }
        return surveyCycle
    }
    
    
    func isBeaconStationDetectionEnabled() -> Bool{
        var beaconStationDetectionEnabled:Bool = true
        if self.getUserDefaults().objectForKey(UserDefaultHelper.BEACON_STATION_DETECTION_KEY) != nil {
            beaconStationDetectionEnabled = self.getUserDefaults().boolForKey(UserDefaultHelper.BEACON_STATION_DETECTION_KEY)
        }
        return beaconStationDetectionEnabled
    }
    
    
    func shouldAskForMapDownload() -> Bool{
        var askForMapDownload:Bool = true
        if self.getUserDefaults().objectForKey(UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY) != nil {
            askForMapDownload = self.getUserDefaults().boolForKey(UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY)
        }
        return askForMapDownload
    }
    
    func setAskForMapDownload(value:Bool){
        self.getUserDefaults().setBool(value, forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY)
        self.getUserDefaults().synchronize()
    }
    
    func getAskedForDownloadsNoCount() -> Int{
        var askedForDownloadsNoCount:Int = 0
        if self.getUserDefaults().objectForKey(UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_KEY) != nil {
            askedForDownloadsNoCount = self.getUserDefaults().integerForKey(UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY)
        }
        return askedForDownloadsNoCount
    }
    
    func incrementAskedForDownloadsNoCount() {
        let askedForDownloadsNoCount = self.getAskedForDownloadsNoCount() + 1
        self.getUserDefaults().setInteger(askedForDownloadsNoCount, forKey: UserDefaultHelper.ASK_FOR_MAPS_DOWNLOAD_NO_COUNT_KEY)
        self.getUserDefaults().synchronize()
    }
    
    func setPrivacyHtml(value:String){
        self.getUserDefaults().setValue(value, forKey: UserDefaultHelper.PRIVACY_HTML_KEY)
        self.getUserDefaults().synchronize()
    }
    
    func getPrivacyHtml() -> String{
        var privacyHtml:String = ""
        if self.getUserDefaults().objectForKey(UserDefaultHelper.PRIVACY_HTML_KEY) != nil {
            privacyHtml = self.getUserDefaults().stringForKey(UserDefaultHelper.PRIVACY_HTML_KEY)!
        }
        return privacyHtml
    }
    
    func getCurrentBusStop() -> Int? {
        var currentBusStop:Int? = nil
        var currentBusStopTimeStamp:Int? = nil
        if self.getUserDefaults().objectForKey(UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY) != nil {
            currentBusStop = self.getUserDefaults().integerForKey(UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY)
        }
        
        if self.getUserDefaults().objectForKey(UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY) != nil {
            currentBusStopTimeStamp = self.getUserDefaults().integerForKey(UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY)
        }
        
        if  currentBusStopTimeStamp != nil &&
            currentBusStop != nil {
        
            let nowTimeStamp = Int(NSDate().timeIntervalSince1970)
            let difference = nowTimeStamp - currentBusStopTimeStamp!
            if difference < Configuration.busStopValiditySeconds {
                return currentBusStop
            } else {
                UserDefaultHelper.instance.setCurrentBusStopId(nil)
                return nil
            }
        } else {
            return nil
        }
        
    }
    
    func setCurrentBusStopId(value:Int? = nil) {
        if value == nil {
            self.getUserDefaults().removeObjectForKey(UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY)
            self.getUserDefaults().removeObjectForKey(UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY)
        } else {
            self.getUserDefaults().setValue(value, forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_KEY)
            self.getUserDefaults().setValue(Int(NSDate().timeIntervalSince1970), forKey: UserDefaultHelper.BEACON_CURRENT_BUS_STOP_TIMESTAMP_KEY)
        }
        self.getUserDefaults().synchronize()
    }
}