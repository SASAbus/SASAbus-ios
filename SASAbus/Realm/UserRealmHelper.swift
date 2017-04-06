import Foundation
import RealmSwift
import Realm
import RxSwift
import RxCocoa

class UserRealmHelper {

    /**
     * Version should not be in YY MM DD Rev. format as it makes upgrading harder.
     */
    static let DB_VERSION: Int = 1
    static let DB_NAME: String = "default.realm"

    /**
     * Initializes the default realm instance, being the user database. This database holds all
     * user specific data, e.g. favorite lines/bus stops or trips.
     *
     * @param context Context needed to build the {@link RealmConfiguration}.
     */
    static func setup() {
        var config = Realm.Configuration()
        config.schemaVersion = 2

        config.objectTypes = [
                FavoriteLine.self,
                FavoriteBusStop.self,
                Trip.self,
                EarnedBadge.self
        ]

        config.deleteRealmIfMigrationNeeded = true

        config.fileURL = config.fileURL!.deletingLastPathComponent()
                .appendingPathComponent(DB_NAME)

        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config

        do {
            _ = try Realm(configuration: config)
        } catch {
            Log.error("Could not open user realm: \(error)")
        }
    }

    // ======================================= RECENTS =============================================

    static func insertRecent(departureId: Int, arrivalId: Int) {
        /*if (!recentExists(departureId, arrivalId)) {
        Realm realm = Realm.getDefaultInstance();

        int maxId = 0;
        Number max = realm.where(RecentRoute.class).max("id");
        if (max != null) {
        maxId = max.intValue() + 1;
        }

        realm.beginTransaction();

        RecentRoute recentRoute = realm.createObject(RecentRoute.class);
        recentRoute.setId(maxId);
        recentRoute.setDepartureId(departureId);
        recentRoute.setArrivalId(arrivalId);

        realm.commitTransaction();
        realm.close();
        }*/
    }

    static func deleteRecent(id: Int) {
        /*Realm realm = Realm.getDefaultInstance();

        RecentRoute recentRoute = realm.where(RecentRoute.class).equalTo("id", id).findFirst();

        realm.beginTransaction();
        recentRoute.deleteFromRealm();
        realm.commitTransaction();

        realm.close();*/
    }

    static func recentExists(departureId: Int, arrivalId: Int) -> Bool {
        /*Realm realm = Realm.getDefaultInstance();

        int count = realm.where(RecentRoute.class).equalTo("departureId", departureId).or()
        .equalTo("arrivalId", arrivalId).findAll().size();

        realm.close();

        return count > 0;*/

        return false
    }

    // ====================================== FAVORITES ============================================

    static func addFavoriteLine(lineId: Int) {
        let realm = try! Realm()

        if hasFavoriteLine(lineId: lineId) {
            // Line already exists in database, skip it.
            Log.debug("Favorite line \(lineId) already exists, skipping.")
            return
        }

        let favoriteLine = FavoriteLine()
        favoriteLine.id = lineId

        try! realm.write {
            realm.add(favoriteLine)
        }

        Log.debug("Added favorite line \(lineId)")
    }

    static func addFavoriteBusStop(busStopGroup: Int) {
        let realm = try! Realm()

        if hasFavoriteBusStop(busStopGroup: busStopGroup) {
            // Bus stop group already exists in database, skip it.
            Log.debug("Favorite bus stop group \(busStopGroup) already exists, skipping.")
            return
        }

        let favoriteBusStop = FavoriteBusStop()
        favoriteBusStop.group = busStopGroup

        try! realm.write {
            realm.add(favoriteBusStop)
        }

        Log.debug("Added favorite bus stop group \(busStopGroup)")
    }

    static func removeFavoriteLine(lineId: Int) {
        let realm = try! Realm()

        let line = realm.objects(FavoriteLine.self).filter("id = \(lineId)").first
        if line != nil {
            try! realm.write {
                realm.delete(line!)
            }
        }

        Log.debug("Removed favorite line \(lineId)")
    }

    static func removeFavoriteBusStop(busStopGroup: Int) {
        let realm = try! Realm()

        let busStop = realm.objects(FavoriteBusStop.self).filter("group = \(busStopGroup)").first
        if busStop != nil {
            try! realm.write {
                realm.delete(busStop!)
            }
        }

        Log.debug("Removed favorite bus stop group \(busStopGroup)")
    }

    static func hasFavoriteLine(lineId: Int) -> Bool {
        let realm = try! Realm()
        return realm.objects(FavoriteLine.self).filter("id = \(lineId)").count > 0
    }

    static func hasFavoriteBusStop(busStopGroup: Int) -> Bool {
        let realm = try! Realm()
        return realm.objects(FavoriteBusStop.self).filter("group = \(busStopGroup)").count > 0
    }

    // ======================================= TRIPS ===============================================

    static func insertTrip(beacon: BusBeacon) -> Bool {
        // Save the beacon trip list to a temporary list.
        var stops: [Int] = Array(beacon.busStops)
        beacon.busStops.removeAll()

        var startIndex = stops.index(of: beacon.origin) ?? -1

        if startIndex == -1 || startIndex + 1 > stops.count {
            Log.error("Trip %s startIndex invalid", beacon.id)
            return false
        }

        // Get the stops from the didEnterRegion index till the end of the list.
        stops = Array(stops[(startIndex + 1)..<stops.count])

        var stopIndex = stops.index(of: beacon.destination) ?? -1

        // Check if the end index is bigger than 0, thus it exists in the list.
        if stopIndex == -1 {
            Log.error("Trip \(beacon.id) stopIndex == -1, destination=\(beacon.destination), stops=\(stops)")
            return false
        }

        // Get the stops from the didEnterRegion index till the end index.
        var endIndex = stopIndex + 1 > stops.count ? stops.count : stopIndex + 1
        var stopList: [Int] = Array(stops[0..<endIndex])

        if stopList.isEmpty {
            Log.error("Trip \(beacon.id) invalid, stopList.isEmpty: stops=\(stops), origin=\(beacon.origin), " +
                    "destination=\(beacon.destination)")

            return false
        }

        stopList.insert(beacon.origin, at: 0)

        var sb = ""

        for i in stopList {
            sb += "\(i), "
        }

        sb = String(sb.characters.dropLast(2))

        var realm = try! Realm()

        var trip = Trip()
        trip.vehicle = beacon.id
        trip.tripHash = beacon.tripHash

        trip.lines = beacon.lines.flatMap {
            String($0)
        }.joined(separator: Config.DELIMITER)

        trip.variants = beacon.variants.flatMap {
            String($0)
        }.joined(separator: Config.DELIMITER)

        trip.trips = beacon.trips.flatMap {
            String($0)
        }.joined(separator: Config.DELIMITER)

        trip.origin = beacon.origin
        trip.destination = beacon.destination
        trip.departure = beacon.startDate.millis() / 1000
        trip.arrival = beacon.lastSeen / 1000
        trip.path = sb
        trip.fuelPrice = Config.DIESEL_PRICE

        try! realm.write {
            realm.add(trip)
        }

        Log.warning("Inserted trip \(beacon.tripHash)")

        // Only post the trip if the user is logged in, as trip uploads are restricted to
        // eco point users only.
        if AuthHelper.isLoggedIn() {
            var cloudTrip = CloudTrip(trip: trip)
            TripSyncHelper.upload(trips: [cloudTrip], scheduler: MainScheduler.background)
        } else {
            Log.info("Skipping trip upload, user not logged in")
        }

        return true
    }

// ===================================== DISRUPTIONS ===========================================

    static func getDisruptionLines() -> [Int] {
        /*Realm realm = Realm.getDefaultInstance();

        Collection<DisruptionLine> result = realm.copyFromRealm(realm.where(DisruptionLine.class)
        .findAll());

        List<Integer> lines = new ArrayList<>();

        for (DisruptionLine line : result) {
        lines.add(line.getLine());
        }

        realm.close();

        return lines;*/

        return []
    }

    static func setDisruptionLines(lines: [Int]) {
        /*Realm realm = Realm.getDefaultInstance();

        realm.beginTransaction();
        realm.where(DisruptionLine.class).findAll().deleteAllFromRealm();
        realm.commitTransaction();

        for (Integer line : lines) {
        realm.beginTransaction();

        DisruptionLine disruptionLine = realm.createObject(DisruptionLine.class);
        disruptionLine.setLine(line);

        realm.commitTransaction();
        }

        realm.close();*/
    }

    static func getDisruptionTimes() -> [Int] {
        /*Realm realm = Realm.getDefaultInstance();

        Collection<DisruptionTime> result = realm.copyFromRealm(realm.where(DisruptionTime.class)
        .findAll());

        List<Integer> times = new ArrayList<>();

        for (DisruptionTime line : result) {
        times.add(line.getTime());
        }

        realm.close();

        return times;*/

        return []
    }

    static func setDisruptionTimes(times: [Int]) {
        /*Realm realm = Realm.getDefaultInstance();

        realm.beginTransaction();
        realm.where(DisruptionTime.class).findAll().deleteAllFromRealm();
        realm.commitTransaction();

        for (Integer time : times) {
        realm.beginTransaction();

        DisruptionTime disruptionTime = realm.createObject(DisruptionTime.class);
        disruptionTime.setTime(time);

        realm.commitTransaction();
        }

        realm.close();*/
    }

// ===================================== DISRUPTIONS ===========================================

    static func setFilter(lines: [Int]) {
        /*Realm realm = Realm.getDefaultInstance();

        realm.beginTransaction();
        realm.where(FilterLine.class).findAll().deleteAllFromRealm();
        realm.commitTransaction();

        for (Integer line : lines) {
        realm.beginTransaction();

        FilterLine filterLine = realm.createObject(FilterLine.class);
        filterLine.setLine(line);

        realm.commitTransaction();
        }

        realm.close();

        LogUtils.w(TAG, "Updated filter");*/
    }

    static func getFilter() -> [Int] {
        /*Realm realm = Realm.getDefaultInstance();

        Collection<FilterLine> result = realm.copyFromRealm(realm.where(FilterLine.class).findAll());
        Collection<Integer> lines = new ArrayList<>();

        for (FilterLine line : result) {
        lines.add(line.getLine());
        }

        realm.close();

        if (lines.isEmpty()) {
        lines.add(100001);
        lines.add(100003);
        lines.add(100004);

        for (int i = 4; i < Lines.checkBoxesId.length; i++) {
        lines.add(Lines.checkBoxesId[i]);
        }
        }

        return lines;*/

        return []
    }

// ======================================= BEACONS =============================================

/*public static void addBeacon(org.altbeacon.beacon.Beacon beacon, String type) {
Realm realm = Realm.getDefaultInstance();

int major = beacon.getId2().toInt();
int minor = beacon.getId3().toInt();

if (major == 1 && minor != 1) {
major = beacon.getId3().toInt();
minor = beacon.getId2().toInt();
}

realm.beginTransaction();

Beacon realmObject = realm.createObject(Beacon.class);
realmObject.setType(type);
realmObject.setMajor(major);
realmObject.setMinor(minor);
realmObject.setTimeStamp((int) (System.currentTimeMillis() / 1000));

realm.commitTransaction();
realm.close();

LogUtils.i(TAG, "Added beacon " + major + " to realm");
}*/

// ======================================= BADGES ==============================================

    static func hasEarnedBadge(badgeId: Int) -> Bool {
        var realm = try! Realm()

        var badge = realm.objects(EarnedBadge.self).filter("id == \(badgeId)").first

        return badge != nil
    }

    static func setEarnedBadge(badgeId: Int) {
        var realm = try! Realm()

        var badge = EarnedBadge()
        badge.id = badgeId

        try! realm.write {
            realm.add(badge)
        }
    }
}
