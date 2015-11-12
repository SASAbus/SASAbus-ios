//
// MapJavascriptBridge.swift
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

import UIKit
import DrawerController

class MapJavascriptBridge {
    
    var initialLat: Double!
    var initialLon: Double!
    var initialZoom: Int!
    var selectButtonText: String!
    var webView: UIWebView!
    var requestLocationStatus: String! = "searching"
    var recOrt: String!
    let viewController: UIViewController!
    
    init(viewController: UIViewController, webView: UIWebView, initialLat: Double, initialLon: Double, initialZoom: Int, selectButtonText: String) {
        
        self.viewController = viewController
        self.webView = webView
        self.initialLat = initialLat
        self.initialLon = initialLon
        self.initialZoom = initialZoom
        self.selectButtonText = selectButtonText
        
        var content = SasaDataHelper.instance.getData("REC_ORT", defaultValue: "[]")
        content = content?.stringByReplacingOccurrencesOfString("\'", withString:"\\'");
        self.recOrt = "{\"list\":"+content!+"}";
    }
    
    
    private func getJavascriptInitialParameters() -> String {
        var javascript = "this.initialParameters = function(){"
            javascript += "return '" + self.initialLat.description
            javascript += "," + self.initialLon.description
            javascript += "," + self.initialZoom.description
            javascript += "," + self.selectButtonText + ", it';"
            javascript += "};"
        return javascript
    }
    
    func setRequestLocation(latidute: Double, longitued : Double, accurancy: Double) {
        let newrequestLocationStatus = latidute.description + "," +
                                       longitued.description + "," +
                                       accurancy.description;
        
        self.changeRequestLocation(newrequestLocationStatus)
    }
    
    func disableRequestLocation() {
        self.changeRequestLocation("stop")
    }
    
    private func changeRequestLocation(newrequestLocationStatus: String) {
        
        if (self.requestLocationStatus != newrequestLocationStatus) {
            self.requestLocationStatus = newrequestLocationStatus
            self.loadJavascript()
        }
    }
    
    private func getJavascriptGetData() -> String {
        var javascript = "this.getData = function(key){"
        javascript += "return '" + self.recOrt + "';"
        javascript += "};"
        return javascript
    }
    
    private func getJavascriptShowDepartures() -> String {
        var javascript = "this.showDepartures = function(busStationName){"
        javascript += "window.location  = 'ios:showDepartures/'+busStationName;";
        javascript += "return busStationName;"
        javascript += "};"
        return javascript
    }
    
    private func getJavascriptGetMapTilesRootUrl() -> String {
        
        var mapTilesUrl:String = Configuration.mapOnlineTiles
        
        //using downloaded tiles as primary resource if they exist
        if UserDefaultHelper.instance.getMapDownloadStatus() == true {
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            mapTilesUrl = (directoryURL.URLByAppendingPathComponent(Configuration.mapTilesDirectory) as NSURL).description
        }
        
        var javascript = "this.getMapTilesRootUrl = function(){"
        javascript += "return '" + mapTilesUrl + "';"
        javascript += "};"
        return javascript
    }
    
    private func getJavascriptGetRequestLocationStatus() -> String {
        var javascript = "this.getRequestLocationStatus = function(){"
        javascript += "return '"+self.requestLocationStatus+"';"
        javascript += "};"
        return javascript
    }
    
    func loadJavascript() {
        let javascript = "window.it_sasabz_sasabus_webmap_client_GWTSASAbusOpenDataLocalStorage=new function(){" +
                self.getJavascriptInitialParameters() +
                self.getJavascriptGetMapTilesRootUrl() +
                self.getJavascriptGetRequestLocationStatus() +
                self.getJavascriptGetData() +
                self.getJavascriptShowDepartures() +
                "};"
        
        self.webView.stringByEvaluatingJavaScriptFromString(javascript)
        
    }
    
    func handleCallsFromJavascript(url:NSURL) {
        var urlString = url.description
        urlString = urlString.stringByReplacingOccurrencesOfString("ios:", withString: "")
        let urlStringArr = urlString.componentsSeparatedByString("/")
        
        let method = urlStringArr[0]
        if method == "showDepartures" {
            let parameter = urlStringArr[1].stringByRemovingPercentEncoding!
            self.showDeparture(parameter)
        }
    }
    
    func showDeparture(departure:String) {
        let nameParts = departure.characters.split {$0 == "("}
        let stationName = String(nameParts[0]).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).lowercaseString
        let communityName = String(nameParts[1]).stringByReplacingOccurrencesOfString(")", withString: "").lowercaseString
        let busStation = (SasaDataHelper.instance.getDataForRepresentation(SasaDataHelper.BusStations) as [BusStationItem]).filter({$0.getCommunity().lowercaseString.containsString(communityName)}).find({$0.getName().lowercaseString.containsString(stationName)})
        if busStation != nil {
            self.openBusStation(busStation!)
        }
    }
    
    private func openBusStation(busStation: BusStationItem) {
        var busstopViewController: BusstopViewController!
        if self.viewController.navigationController?.viewControllers.count > 1 {
            busstopViewController = self.viewController.navigationController?.viewControllers[(self.viewController.navigationController?.viewControllers.indexOf(self.viewController))! - 1] as? BusstopViewController
            busstopViewController!.setBusStation(busStation)
            self.viewController.navigationController?.popViewControllerAnimated(true)
        } else {
            busstopViewController = BusstopViewController(busStation: busStation, nibName: "BusstopViewController", title: NSLocalizedString("Busstop", comment:""))
            (UIApplication.sharedApplication().delegate as! AppDelegate).navigateTo(busstopViewController!)
        }
    }
}