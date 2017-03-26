import Foundation
import RealmSwift

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
        config.schemaVersion = 1
        
        config.objectTypes = [
            FavoriteLine.self,
            FavoriteBusStop.self
        ]
        
        config.fileURL = config.fileURL!.deletingLastPathComponent()
            .appendingPathComponent(DB_NAME)
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm(configuration: config)
        } catch let error {
            print("Could not open user realm: \(error)")
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
    
    /*static func insertTrip(beacon: BusBeacon) {
    /*// Save the beacon trip list to a temporary list.
    List<Integer> stops = new ArrayList<>(beacon.busStops);
    beacon.busStops.clear();
    
    int startIndex = stops.indexOf(beacon.origin);
    
    if (startIndex == -1 || startIndex + 1 > stops.size()) {
    Utils.throwTripError(sContext, "Trip " + beacon.id + " startIndex invalid");
    return false;
    }
    
    // Get the stops from the start index till the end of the list.
    stops = stops.subList(startIndex + 1, stops.size());
    
    int stopIndex = stops.indexOf(beacon.destination);
    
    // Check if the end index is bigger than 0, thus it exists in the list.
    if (stopIndex == -1) {
    Utils.throwTripError(sContext, "Trip " + beacon.id + " stopIndex == -1");
    return false;
    }
    
    // Get the stops from the start index till the end index.
    int endIndex = stopIndex + 1 > stops.size() ? stops.size() : stopIndex + 1;
    List<Integer> stopList = stops.subList(0, endIndex);
    
    if (stopList.isEmpty()) {
    Utils.throwTripError(sContext, "Trip " + beacon.id + " invalid -> stopList empty\n\n" +
    "list: " + Arrays.toString(stops.toArray()) + "\n\n" +
    "start: " + beacon.origin + '\n' +
    "stop: " + beacon.destination);
    
    return false;
    }
    
    stopList.add(0, beacon.origin);
    
    StringBuilder sb = new StringBuilder();
    
    for (int i = 0; i < stopList.size(); i++) {
    sb.append(stopList.get(i)).append(',');
    }
    
    sb.setLength(sb.length() - 1);
    
    Realm realm = Realm.getDefaultInstance();
    realm.beginTransaction();
    
    Trip trip = realm.createObject(Trip.class);
    trip.setHash(beacon.hash);
    trip.setLine(beacon.lineId);
    trip.setVehicle(beacon.id);
    trip.setVariant(beacon.variant);
    trip.setTrip(beacon.trip);
    trip.setOrigin(beacon.origin);
    trip.setDestination(beacon.destination);
    trip.setDeparture(beacon.getStartDate().getTime() / 1000);
    trip.setArrival(beacon.lastSeen / 1000);
    trip.setPath(sb.toString());
    trip.setFuelPrice(beacon.fuelPrice);
    
    realm.commitTransaction();
    realm.close();
    
    LogUtils.w(TAG, "Inserted trip " + beacon.hash);
    
    return true;*/
    }
    
    static func insertTrip(cloudTrip: CloudTrip) {
    /*Realm realm = Realm.getDefaultInstance();
    realm.beginTransaction();
    
    Trip trip = realm.createObject(Trip.class);
    trip.setHash(cloudTrip.hash);
    trip.setLine(cloudTrip.line);
    trip.setVehicle(cloudTrip.vehicle);
    trip.setVariant(cloudTrip.variant);
    trip.setTrip(cloudTrip.trip);
    trip.setOrigin(cloudTrip.origin);
    trip.setDestination(cloudTrip.destination);
    trip.setDeparture(cloudTrip.departure);
    trip.setArrival(cloudTrip.arrival);
    trip.setPath(Utils.listToString(cloudTrip.path, ","));
    trip.setFuelPrice(cloudTrip.dieselPrice);
    
    realm.commitTransaction();
    realm.close();
    
    LogUtils.w(TAG, "Inserted trip " + cloudTrip.hash);*/
    }*/
    
    
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
    /*Realm realm = Realm.getDefaultInstance();
    
    EarnedBadge badge = realm.where(EarnedBadge.class).equalTo("id", badgeId).findFirst();
    
    boolean result = badge != null;
    
    realm.close();
    
    return result;*/
        
        return false
    }
    
    static func setEarnedBadge(badgeId: Int) {
    /*Realm realm = Realm.getDefaultInstance();
    
    realm.beginTransaction();
    
    EarnedBadge badge = realm.createObject(EarnedBadge.class);
    badge.setId(badgeId);
    
    realm.commitTransaction();
    
    realm.close();*/
    }
}
