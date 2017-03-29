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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <<T:Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func ><T:Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


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

        var content = SasaDataHelper.getData("REC_ORT", defaultValue: "[]")
        content = content?.replacingOccurrences(of: "\'", with: "\\'");
        self.recOrt = "{\"list\":" + content! + "}";
    }


    fileprivate func getJavascriptInitialParameters() -> String {
        var javascript = "this.initialParameters = function(){"
        javascript += "return '" + self.initialLat.description
        javascript += "," + self.initialLon.description
        javascript += "," + self.initialZoom.description
        javascript += "," + self.selectButtonText + ", it';"
        javascript += "};"
        return javascript
    }

    func setRequestLocation(_ latidute: Double, longitude: Double, accuracy: Double) {
        let newrequestLocationStatus = latidute.description + "," +
                longitude.description + "," +
                accuracy.description;

        self.changeRequestLocation(newrequestLocationStatus)
    }

    func disableRequestLocation() {
        self.changeRequestLocation("stop")
    }

    fileprivate func changeRequestLocation(_ newrequestLocationStatus: String) {

        if (self.requestLocationStatus != newrequestLocationStatus) {
            self.requestLocationStatus = newrequestLocationStatus
            self.loadJavascript()
        }
    }

    fileprivate func getJavascriptGetData() -> String {
        var javascript = "this.getData = function(key){"
        javascript += "return '" + self.recOrt + "';"
        javascript += "};"
        return javascript
    }

    fileprivate func getJavascriptShowDepartures() -> String {
        var javascript = "this.showDepartures = function(busStationName){"
        javascript += "window.location  = 'ios:showDepartures/'+busStationName;";
        javascript += "return busStationName;"
        javascript += "};"
        return javascript
    }

    fileprivate func getJavascriptGetMapTilesRootUrl() -> String {
        var mapTilesUrl: String = Config.mapOnlineTiles

        //using downloaded tiles as primary resource if they exist
        if UserDefaultHelper.instance.getMapDownloadStatus() == true {
            let fileManager = FileManager.default
            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            mapTilesUrl = (directoryURL.appendingPathComponent(Config.MAP_FOLDER) as URL).description
        }

        var javascript = "this.getMapTilesRootUrl = function(){"
        javascript += "return '" + mapTilesUrl + "';"
        javascript += "};"
        return javascript
    }

    fileprivate func getJavascriptGetRequestLocationStatus() -> String {
        var javascript = "this.getRequestLocationStatus = function(){"
        javascript += "return '" + self.requestLocationStatus + "';"
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

        self.webView.stringByEvaluatingJavaScript(from: javascript)

    }

    func handleCallsFromJavascript(_ url: URL) {
        var urlString = url.description
        urlString = urlString.replacingOccurrences(of: "ios:", with: "")
        let urlStringArr = urlString.components(separatedBy: "/")

        let method = urlStringArr[0]
        if method == "showDepartures" {
            let parameter = urlStringArr[1].removingPercentEncoding!
            self.showDeparture(parameter)
        }
    }

    func showDeparture(_ departure: String) {
        let nameParts = departure.characters.split {
            $0 == "("
        }

        let stationName = String(nameParts[0]).trimmingCharacters(in: NSCharacterSet.whitespaces).lowercased()
        let communityName = String(nameParts[1]).replacingOccurrences(of: ")", with: "").lowercased()
        let busStation = (SasaDataHelper.getData(SasaDataHelper.REC_ORT) as [BusStationItem])
                .filter({ $0.community.lowercased().contains(communityName) })
                .find({ $0.name.lowercased().contains(stationName) })

        if busStation != nil {
            self.openBusStation(busStation!)
        }
    }

    fileprivate func openBusStation(_ busStation: BusStationItem) {
        var busstopViewController: BusStopViewController!

        if self.viewController.navigationController?.viewControllers.count > 1 {
            busstopViewController = self.viewController.navigationController?.viewControllers[(self.viewController.navigationController?.viewControllers.index(of: self.viewController))! - 1] as? BusStopViewController
            busstopViewController!.setBusStation(busStation)
            self.viewController.navigationController?.popViewController(animated: true)
        } else {
            busstopViewController = BusStopViewController(busStation: busStation, title: NSLocalizedString("Busstop", comment: ""))
            (UIApplication.shared.delegate as! AppDelegate).navigateTo(busstopViewController!)
        }
    }
}
