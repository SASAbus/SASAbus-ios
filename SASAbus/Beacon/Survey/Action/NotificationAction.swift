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

class NotificationAction:SurveyActionProtocol {
    
    func triggerSurvey(beaconInfo:SurveyBeaconInfo) {
    
        Alamofire.request(SurveyApiRouter.GetSurvey).responseObject{ (response: Response<SurveyItem, NSError>) in
            if response.result.isSuccess {
                if response.result.value != nil  {
                    let surveyDefinition:SurveyItem = response.result.value!
                    if surveyDefinition.getStatus() == "success" {
                        
                        let firstQuestion = self.getFirstQuestion(surveyDefinition, beaconInfo:beaconInfo);
                        let localNotification = UILocalNotification()
                        if #available(iOS 8.2, *) {
                            localNotification.alertTitle = NSLocalizedString("Survey", comment: "")
                        }
                        localNotification.alertBody = firstQuestion
                        localNotification.alertAction =  NSLocalizedString("Survey", comment: "")
                        localNotification.fireDate = NSDate()
                        localNotification.timeZone = NSTimeZone.defaultTimeZone()
                        localNotification.soundName = UILocalNotificationDefaultSoundName
                        localNotification.applicationIconBadgeNumber = 1
                        localNotification.category = "surveyCategory"
                        var info = [NSObject:AnyObject]()
                        
                        info["firstQuestion"] = firstQuestion;
                        info["secondQuestion"] = surveyDefinition.getSecondQuestionLocalized()
                        info["user_id"] = UIDevice.currentDevice().identifierForVendor!.UUIDString
                        info["frt_id"] = ""
                        if  beaconInfo.getTripId() != nil {
                            info["frt_id"] = beaconInfo.getTripId()!
                        }
                        
                        info["trip_duration"] = beaconInfo.getSeenSeconds()
                        info["bus_id"] = beaconInfo.getMajor()
                        
                        info["start_busstop_id"] = ""
                        if beaconInfo.getStartBusStop() != nil {
                            info["start_busstop_id"] = beaconInfo.getStartBusStop()!
                        }
                        
                        info["stop_busstop_id"] = ""
                        if beaconInfo.getStopBusStop() != nil {
                            info["stop_busstop_id"] = beaconInfo.getStopBusStop()!
                        }
                        localNotification.userInfo = info
                        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                        UserDefaultHelper.instance.setLastSurveyTimeStamp(Int(NSDate().timeIntervalSince1970))
                    }
                }
            }
        }

    }
    
    
    private func getFirstQuestion(surveyDefinition:SurveyItem , beaconInfo:SurveyBeaconInfo) -> String! {
        var firstQuestion = surveyDefinition.getFirstQuestionLocalized()
        
        if beaconInfo.getLineName() != nil &&
           !beaconInfo.getLineName()!.isEmpty {
            let firstQuestionPlaceHolder = surveyDefinition.getFirstQuestionPlaceholderLocalized();
            firstQuestion = firstQuestionPlaceHolder.stringByReplacingOccurrencesOfString("%s", withString: beaconInfo.getLineName()!)
        }
        return firstQuestion
    }
    
}