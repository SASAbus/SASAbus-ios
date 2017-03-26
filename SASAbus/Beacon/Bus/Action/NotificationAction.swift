//
// NotificationAction.swift
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
import Alamofire
import SwiftyJSON

class NotificationAction: SurveyActionProtocol {

    func triggerSurvey(_ beaconInfo: SurveyBeaconInfo) {

        Alamofire.request(SurveyApiRouter.getSurvey).responseJSON(completionHandler: { response in
            if response.result.isSuccess {
                let surveyDefinition: SurveyItem = SurveyItem(parameter: JSON(response.data))

                if surveyDefinition.status == "success" {
                    let firstQuestion = self.getFirstQuestion(surveyDefinition, beaconInfo: beaconInfo);
                    let localNotification = UILocalNotification()

                    if #available(iOS 8.2, *) {
                        localNotification.alertTitle = NSLocalizedString("Survey", comment: "")
                    }

                    localNotification.alertBody = firstQuestion
                    localNotification.alertAction = NSLocalizedString("Survey", comment: "")
                    localNotification.fireDate = Date()

                    localNotification.timeZone = NSTimeZone.default
                    localNotification.soundName = UILocalNotificationDefaultSoundName
                    localNotification.applicationIconBadgeNumber = 1
                    localNotification.category = "surveyCategory"

                    var info = [String: AnyObject?]()

                    info["firstQuestion"] = firstQuestion as AnyObject??
                    info["secondQuestion"] = surveyDefinition.getSecondQuestionLocalized() as AnyObject??
                    info["user_id"] = UIKit.UIDevice.current.identifierForVendor!.uuidString as AnyObject??
                    info["trip_duration"] = beaconInfo.seconds as AnyObject??
                    info["bus_id"] = beaconInfo.major as AnyObject??

                    info["frt_id"] = "" as AnyObject??
                    if beaconInfo.getTripId() != nil {
                        info["frt_id"] = beaconInfo.getTripId()! as AnyObject??
                    }

                    info["start_busstop_id"] = "" as AnyObject??
                    if beaconInfo.getStartBusStop() != nil {
                        info["start_busstop_id"] = beaconInfo.getStartBusStop()!  as AnyObject??
                    }

                    info["stop_busstop_id"] = "" as AnyObject??
                    if beaconInfo.getStopBusStop() != nil {
                        info["stop_busstop_id"] = beaconInfo.getStopBusStop()! as AnyObject??
                    }

                    localNotification.userInfo = info
                    UIKit.UIApplication.shared.scheduleLocalNotification(localNotification)
                    UserDefaultHelper.instance.setLastSurveyTimeStamp(Int(NSDate().timeIntervalSince1970))
                }
            }
        })
    }


    fileprivate func getFirstQuestion(_ surveyDefinition: SurveyItem, beaconInfo: SurveyBeaconInfo) -> String! {
        var firstQuestion = surveyDefinition.getFirstQuestionLocalized()

        if beaconInfo.getLineName() != nil &&
                   !beaconInfo.getLineName()!.isEmpty {
            let firstQuestionPlaceHolder = surveyDefinition.getFirstQuestionPlaceholderLocalized();
            firstQuestion = firstQuestionPlaceHolder.replacingOccurrences(of: "%s", with: beaconInfo.getLineName()!)
        }
        return firstQuestion
    }

}
