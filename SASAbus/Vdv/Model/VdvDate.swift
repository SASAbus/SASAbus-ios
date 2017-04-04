//
// Created by Alex Lardschneider on 03/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation

class VdvDate {

    var id: Int
    var date: Date

    init(id: Int, date: Date) {
        self.id = id
        self.date = date
    }

    public var description: String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"

        return "{id=\(id), date=\(format.string(from: date))}"
    }
}
