import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
import RealmSwift

class TripSyncHelper {

    static func upload(trips: [CloudTrip], scheduler: SchedulerType) {
        Log.warning("Uploading \(trips.count) trips")

        _ = CloudApi.uploadTrips(trips: trips)
                .subscribeOn(scheduler)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { json in
                    Log.error("Got \(json["earned_badges"].arrayValue.count) new badges to display")

                    print(json)

                    DispatchQueue(label: "com.app.queue", qos: .background).async {
                        // TODO

                        /*for (badge in response.badges) {
                            Notifications.badge(context, badge)
                        }*/
                    }

                    let realm = try! Realm()

                    for rejected in json["rejected_trips"].arrayValue {
                        let trip = realm.objects(Trip.self).filter("hash == '\(rejected)'").first

                        if trip != nil {
                            try! realm.write {
                                realm.delete(trip!)
                            }
                        } else {
                            Log.error("Rejected trip with hash '\(rejected)' not found in database")
                        }
                    }
                }, onError: { error in
                    Log.error("Could not upload trips; \(error)")
                })
    }
}