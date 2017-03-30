import Foundation

class CurrentTrip: Serializable {

    var beacon: BusBeacon?

    var path = [BusStop]()

    var times: [ApiBusStop]?

    var isNotificationShown: Bool = false
    var updated: Bool = false
    var hasReachedSecondBusStop: Bool = false

    convenience init(beacon: BusBeacon) {
        self.init()

        self.beacon = beacon

        // TODO
        /*
        // Check for badge
        BadgeHelper.evaluate(mContext, beacon);*/

        setup()
    }

    func setup() {
        path.removeAll()

        if times != nil {
            times?.removeAll()
        }

        hasReachedSecondBusStop = false

        times = Trips.getPath(tripId: (beacon!.getLastTrip()))

        if times == nil || (times?.isEmpty)! {
            /*SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
            
            String date = format.format(new Date());
            
            String message = String.format("times == null. \n" +
                "day type: %s, " +
                "day: %s, " +
                "trip id: %s, " +
                "line: %s, " +
                "variant: %s, " +
                "Trips.TRIPS.size: %s, " +
                "Paths.PATHS.size: %s, " +
                "Paths.PATHS.values.size: %s, " +
                CompanyCalendar.getDayType(date),
                                           date,
                                           beacon.getLastTrip(),
                                           beacon.getLastLine(),
                                           beacon.getLastVariant(),
                                           Trips.getTrips().size(),
                                           Paths.getPaths().size(),
                                           Paths.getPaths().values().size(),
                                           Paths.getPaths().values().size());
            
            Throwable throwable = new Throwable(message);
            
            Utils.logException(throwable);*/

            beacon?.setSuitableForTrip(suitableForTrip: false)

            //NotificationUtils.cancelBus(mContext);

            Log.error("Invalid path for trip \(beacon?.getLastTrip())")
        } else {
            for busStop in times! {
                path.append(BusStopRealmHelper.getBusStop(id: busStop.getId()))
            }
        }
    }

    func checkUpdate() -> Bool {
        let temp = updated
        updated = false
        return temp
    }

    func getId() -> Int {
        return beacon!.id
    }

    func getDelay() -> Int {
        return beacon!.delay
    }

    func setBeacon(beacon: BusBeacon) {
        self.beacon = beacon
    }

    func update() {
        updated = true

        // TODO
        /*if beacon.isSuitableForTrip && BusBeaconHandler.notificationAction != null {
            BusBeaconHandler.notificationAction.showNotification(this);
        }*/
    }

    func setNotificationShown(shown: Bool) {
        isNotificationShown = shown
    }

    func reset() {
        setup()
    }

    func getTimes() -> [ApiBusStop]? {
        return times
    }

    func getTitle() -> String? {
        return beacon?.title
    }

    func getPath() -> [BusStop] {
        return path
    }
}
