//
// Created by Alex Lardschneider on 06/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import RealmSwift

/**
 * A badge object which indicates which badge has been earned.
 *
 * Only the earned badges which are hardcoded in the app are saved here, as the server already
 * knows if the user earned any of the other badges and can supply information about them.
 *
 * @author Alex Lardschneider
 */
class EarnedBadge: Object {

    dynamic var id: Int = 0
    dynamic var sent: Bool = false
}
