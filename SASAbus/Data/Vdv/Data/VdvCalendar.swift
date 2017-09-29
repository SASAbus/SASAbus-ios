//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import SwiftyJSON

class VdvCalendar {

    static var DATE_FORMAT: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }

    static var CALENDAR = [VdvDate]()

    /**
     * This method searches for the current date in the calendar. Note that if the app is being used
     * at midnight and the date suddenly changes, this method needs to be called again to correct
     * the date. As an alternative the app needs to be restarted.
     *
     * @param jCalendar the JSON data with the corresponding information
     * @throws Exception if the json is malformed
     */
    static func loadCalendar(jCalendar: [JSON]) {
        CALENDAR.removeAll()

        for i in 0...jCalendar.count - 1 {
            var jDay = jCalendar[i]

            CALENDAR.append(VdvDate(
                    id: jDay["dt"].intValue,
                    date: DATE_FORMAT.date(from: jDay["da"].stringValue)!
            ))
        }
    }

    public static func today() throws -> VdvDate {
        try assertCalendarInitialized()

        let today = Date()

        for date in CALENDAR {
            if isToday(today: today, toCheck: date.date) {
                return date
            }
        }

        PlannedData.setUpdateAvailable(true)

        // let md5 = HashUtils.md5File(url: VdvHandler.getPlannedDataFile())
        let md5 = ""
        
        let message = "Today (\(DATE_FORMAT.string(from: Date())) doesn't exist in the calendar," +
                " calendar=\(CALENDAR), md5=\(md5)"

        throw VdvError.vdvError(message: message)
    }

    public static func date(_ date: Date) throws -> Int {
        try assertCalendarInitialized()

        let dateString = DATE_FORMAT.string(from: date)

        for d in CALENDAR {
            if DATE_FORMAT.string(from: d.date) == dateString {
                return d.id
            }
        }

        throw VdvError.vdvError(message: "The requested day (\(dateString) doesn't exist in the calendar.")
    }

    private static func isToday(today: Date, toCheck: Date) -> Bool {
        let julianToday = today.millis() / 86400000
        let julianToCheck = toCheck.millis() / 86400000 + 1

        return julianToday == julianToCheck
    }

    private static func assertCalendarInitialized() throws {
        if CALENDAR.isEmpty {
            throw VdvError.vdvError(message: "The calendar must be initialized first, " +
                    "before a date is requested.")
        }
    }
}
