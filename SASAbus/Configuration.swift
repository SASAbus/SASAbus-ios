//
// Configuration.swift
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

struct Configuration {
    
    static let dataFolder = ""
    static let dataUrl:String = ""
    
    // Router
    static let timeoutInterval = 0.0
    
    //download 
    static let downloadTimeoutIntervalForResource = 0.0
    static let downloadTimeoutIntervalForRequest = 0.0
    
    //realtime information
    static let realTimeDataUrl = ""
    
    //privacy
    static let privacyBaseUrl = ""
    
    //map
    static let mapDownloadZip = ""
    static let mapTilesDirectory = ""
    static let mapOnlineTiles = ""
    static let mapStandardLatitude = 0.0
    static let mapStandardLongitude = 0.0
    static let mapStandardZoom = 0
    static let mapHowOftenShouldIAskForMapDownload = 0
    
    //parkinglot
    static let parkingLotBaseUrl = ""
    
    //news
    static let newsApiUrl = ""
    
    //beacon survey (bus)
    static let beaconUid = ""
    static let beaconIdentifier = ""
    static let beaconSecondsInBus = 0
    static let beaconMinTripDistance = 0
    static let beaconLastSeenTreshold = 0
    
    
    //beacon stationdetection (busstops)
    static let busStopBeaconUid = ""
    static let busStopBeaconIdentifier = ""
    static let busStopValiditySeconds = 0
    
    //survey
    static let surveyApiUrl = ""
    static let surveyApiUsername = ""
    static let surveyApiPassword = ""
    static let surveyRecurringTimeDefault = 0
    
    //busstop
    static let busStopDistanceTreshold = 0.0
    
}