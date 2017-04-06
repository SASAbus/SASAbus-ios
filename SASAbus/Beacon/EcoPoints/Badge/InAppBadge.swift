//
// Created by Alex Lardschneider on 06/04/2017.
// Copyright (c) 2017 SASA AG. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class InAppBadge {

    var id: Int
    var title: String
    var summary: String
    var icon: String

    init(id: Int, title: String, summary: String, icon: String) {
        self.id = id
        self.title = title
        self.summary = summary
        self.icon = icon
    }

    func completed() -> Bool {
        return UserRealmHelper.hasEarnedBadge(badgeId: id)
    }

    func complete() {
        UserRealmHelper.setEarnedBadge(badgeId: id)

        EcoPointsApi.sendBadge(id: id)
                .subscribeOn(MainScheduler.background)
                .observeOn(MainScheduler.background)
                .subscribe(onNext: { _ in
                    var realm = try! Realm()

                    var badge = realm.objects(EarnedBadge.self).filter("id == \(self.id)").first

                    if badge == nil {
                        Log.error("InAppBadge with id \(self.id) has been inserted into database, but cannot be queried.")
                        return
                    }

                    try! realm.write {
                        badge!.sent = true
                    }

                    Log.error("Uploaded badge \(self.id)")
                }, onError: { error in
                    Log.error("Could not send earned badge: \(error)")
                })
    }

    /**
     * Evaluates if the badge is completed by checking  different statements match in each badge.
     * Those statements vary by badge, and can be true e.g. if the user scans the first beacon.
     *
     * @param beacon the beacon to evaluate the expression with.
     * @return `true` if the condition has been met, `false` if it hasn't
     */
    open func evaluate(beacon: AbsBeacon) -> Bool {
        // You can only earn the badge if you are logged in, so check for that first.
        return AuthHelper.getTokenIfValid() != nil
    }
}
