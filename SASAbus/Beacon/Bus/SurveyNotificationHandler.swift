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

class SurveyNotificationHandler: NotificationProtocol {

    var name: String!

    init(name: String) {
        self.name = name
    }

    func getName() -> String {
        return self.name
    }

    func handleNotificationForeground(_ viewController: UIViewController, userInfo: [String : Any]?) {
        let surveyAlert = UIAlertController(title: NSLocalizedString("Survey", comment: ""),
                message: String(describing: userInfo!["firstQuestion"]!), preferredStyle: UIAlertControllerStyle.alert)

        surveyAlert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""),
                style: UIAlertActionStyle.default, handler: { _ in
            self.answerIsNo(userInfo!)
        }))

        surveyAlert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""),
                style: UIAlertActionStyle.default, handler: { _ in
            self.answerIsYes(userInfo)
        }))

        viewController.present(surveyAlert, animated: true, completion: nil)
    }

    func handleNotificationBackground(_ identifier: String? = nil, userInfo: [String : Any]?) {
        if identifier == "Yes" {
            self.answerIsYes(userInfo!)
        } else if identifier == "No" {
            self.answerIsNo(userInfo!)
        }
    }


    func answerIsYes(_ notificationInfoItem: [String : Any]?) {
        Notifications.clearAll()

        var surveyData = self.getSurveyDataFromNotificationItem(notificationInfoItem!)

        surveyData["result"] = "y" as AnyObject?
        surveyData["phone"] = "" as AnyObject?
        surveyData["email"] = "" as AnyObject?

        Alamofire.request(SurveyApiRouter.insertSurvey(surveyData)).responseJSON { _ in
        }
    }

    func answerIsNo(_ notificationInfoItem: [String : Any]) {
        Notifications.clearAll()

        let surveyContactViewController = SurveyContactViewController(nibName: "SurveyContactViewController",
                title: NSLocalizedString("Survey", comment: ""))

        var surveyData = self.getSurveyDataFromNotificationItem(notificationInfoItem)

        surveyData["result"] = "n" as AnyObject?
        surveyData["secondQuestion"] = notificationInfoItem["secondQuestion"] as AnyObject?
        surveyContactViewController.surveyData = surveyData
        surveyContactViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navigateTo(surveyContactViewController)
    }

    fileprivate func getSurveyDataFromNotificationItem(_ notificationInfoItem: [String : Any]) -> [String : AnyObject] {
        var surveyData = [String: AnyObject]()

        surveyData["result"] = "y" as AnyObject?
        surveyData["user_id"] = notificationInfoItem["user_id"] as AnyObject?
        surveyData["frt_id"] = notificationInfoItem["frt_id"] as AnyObject?
        surveyData["bus_id"] = notificationInfoItem["bus_id"] as AnyObject?
        surveyData["trip_duration"] = notificationInfoItem["trip_duration"] as AnyObject?
        surveyData["start_busstop_id"] = notificationInfoItem["start_busstop_id"] as AnyObject?
        surveyData["stop_busstop_id"] = notificationInfoItem["stop_busstop_id"] as AnyObject?

        return surveyData
    }

}
