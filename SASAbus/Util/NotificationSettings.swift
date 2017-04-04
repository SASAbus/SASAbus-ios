//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class NotificationSettings {

    static func isSurveyEnabled() -> Bool {
        return true
    }

    static func getLastSurveyMillis() -> Int64 {
        return 0
    }

    static func getSurveyInterval() -> Int {
        return 0
    }
}
