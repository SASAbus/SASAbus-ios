//
// BusstopMapViewController.swift
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
import CoreLocation

class BusstopMapViewController: UIViewController, UIWebViewDelegate, CLLocationManagerDelegate{
    
    var initializedJavascript:DarwinBoolean = false;
    var mapJavascriptBridge:MapJavascriptBridge?
    var locationManager:CLLocationManager?
    
    @IBOutlet weak var mapWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Bus stations map", comment: "")
        self.locationManager = CLLocationManager()
        let path = NSBundle.mainBundle().pathForResource("SASAbusWebMap", ofType: "html", inDirectory: "www/webmap")
        let requestURL = NSURL(string:path!);
        let request = NSURLRequest(URL:requestURL!);
        self.mapJavascriptBridge = MapJavascriptBridge(viewController: self, webView: mapWebView, initialLat: Configuration.mapStandardLatitude, initialLon: Configuration.mapStandardLongitude, initialZoom: Configuration.mapStandardZoom, selectButtonText: NSLocalizedString("Show departures", comment:""))
        mapWebView.loadRequest(request)
        mapWebView.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager!.stopUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.locationManager!.requestAlwaysAuthorization()
        self.locationManager!.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.mapJavascriptBridge?.setRequestLocation(locValue.latitude, longitued: locValue.longitude, accurancy: 5.0)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.URL;
        if url?.scheme == "ios" {
            self.mapJavascriptBridge?.handleCallsFromJavascript(url!);
            return false;
        }
        return true;
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if (initializedJavascript == false) {
            self.mapJavascriptBridge?.loadJavascript()
            initializedJavascript = true;
        }
    }
}