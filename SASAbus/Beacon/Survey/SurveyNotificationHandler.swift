//
// SurveyNotificationHandler.swift
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
import UIKit
import Alamofire

class SurveyNotificationHandler:NotificationProtocol {
    
    var name:String!
    
    init(name:String){
        self.name = name
    }
    
    func getName() -> String {
        return self.name
    }
    
    func handleNotificationForeground(viewController:UIViewController, userInfo:[NSObject:AnyObject]?) {
        let surveyAlert = UIAlertController(title: NSLocalizedString("Survey", comment: ""), message: String(userInfo!["firstQuestion"]!), preferredStyle: UIAlertControllerStyle.Alert)
        surveyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.answereIsNo(userInfo)
        }))
        
        surveyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) in
            self.answereIsYes(userInfo)
            
        }))
        viewController.presentViewController(surveyAlert, animated: true, completion: nil)
    }
    
    func handleNotificationBackground(identifier:String? = nil, userInfo:[NSObject:AnyObject]?) {
        if identifier == "Yes" {
            self.answereIsYes(userInfo)
        } else if identifier == "No" {
            self.answereIsNo(userInfo)
        }
    }
    
    
    func answereIsYes(notificationInfoItem:[NSObject:AnyObject]?) {
        BadgeHelper.instance.clearBadges()
        var surveyData = self.getSurveyDataFromNotificationItem(notificationInfoItem!)
        surveyData["result"] = "y"
        surveyData["phone"] = ""
        surveyData["email"] = ""

        Alamofire.request(SurveyApiRouter.InsertSurvey(surveyData)).responseJSON { response in }
    }
    
    func answereIsNo( notificationInfoItem:[NSObject:AnyObject]!) {
        BadgeHelper.instance.clearBadges()
        let surveyContactViewController = SurveyContactViewController(nibName: "SurveyContactViewController", title: NSLocalizedString("Survey", comment:""))
        var surveyData = self.getSurveyDataFromNotificationItem(notificationInfoItem!)
        surveyData["result"] = "n"
        surveyData["secondQuestion"] = notificationInfoItem["secondQuestion"]
        surveyContactViewController.surveyData = surveyData
        surveyContactViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.navigateTo(surveyContactViewController)
    }
    
    private func getSurveyDataFromNotificationItem(notificationInfoItem:[NSObject:AnyObject]) -> [String:AnyObject]{
        var surveyData = [String:AnyObject]()
        surveyData["result"] = "y"
        surveyData["user_id"] = notificationInfoItem["user_id"]
        surveyData["frt_id"] = notificationInfoItem["frt_id"]
        surveyData["bus_id"] = notificationInfoItem["bus_id"]
        surveyData["trip_duration"] = notificationInfoItem["trip_duration"]
        surveyData["start_busstop_id"] = notificationInfoItem["start_busstop_id"]
        surveyData["stop_busstop_id"] = notificationInfoItem["stop_busstop_id"]
        return surveyData
    }
    
}