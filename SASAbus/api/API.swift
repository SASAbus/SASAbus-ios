import Foundation

/**
 * This is the main offline API where the app gets data from. This API tells us specific information
 * about departures and trips. It uses the SASA SpA-AG offline stored open data.
 *
 * @author Alex Lardschneider
 */
class API {

    static var DATE: DateFormatter!
    static var TIME: DateFormatter!

    static func setup() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        DATE = dateFormatter
        TIME = timeFormatter
    }

    static func getPath(time: Int, line: Int) -> [ApiBusStop] {
        Handler.load()

        var newTime: Int

        let userCalendar = NSCalendar.current
        var date = Date()

        newTime = time % 86400
        if newTime < 5400 {
            newTime += 86400
            date = userCalendar.date(byAdding: Calendar.Component.day, value: -1, to: date)!
        }

        let trips = Trips.getTrips(day: CompanyCalendar.getDayType(date: DATE.string(from: date)), line: line)

        for trip in trips {
            if trip.getSecondsAtUserStop() == time {
                return trip.getPath()
            }
        }

        return []
    }

    static func getPassingLines(family: Int) -> [String] {
        Handler.load()

        let busStops = BusStopRealmHelper.getBusStopsFromFamily(family: family)

        var lines = [String]()

        for (lineId, line) in Paths.getPaths() {
            for (_, variants) in line {
                let variant = Set<ApiBusStop>(variants)

                if !variant.isDisjoint(with: Set<ApiBusStop>(busStops)) {
                    lines.append(Lines.lidToName(id: lineId))
                    break
                }
            }
        }

        lines.sort(by: { (a, b) ->
            Bool in
            var line1 = (a as NSString).replacingOccurrences(of: "A", with: "")
            line1 = (line1 as NSString).replacingOccurrences(of: "B", with: "")

            var line2 = (b as NSString).replacingOccurrences(of: "A", with: "")
            line2 = (line2 as NSString).replacingOccurrences(of: "B", with: "")

            return line1 < line2
        })

        for i in 0..<lines.count {
            let line: String = lines[i]

            if (line as NSString).contains("A") {
                lines[i] = (line as NSString).replacingOccurrences(of: "A", with: "B")
            }

            if (line as NSString).contains("A") {
                lines[i] = (line as NSString).replacingOccurrences(of: "B", with: "A")
            }
        }

        return lines
    }

    static func getPassingLinesIds(family: Int) -> [Int] {
        Handler.load()

        let busStops = BusStopRealmHelper.getBusStopsFromFamily(family: family)

        var lines = [Int]()

        for (lineId, line) in Paths.getPaths() {
            for (_, variants) in line {
                let variant = Set<ApiBusStop>(variants)

                if !variant.isDisjoint(with: Set<ApiBusStop>(busStops)) {
                    lines.append(lineId)
                    break
                }
            }
        }

        lines.sort(by: { (a, b) -> Bool in
            return a < b
        })

        return lines
    }

    static func getDepartures(date: String, time: String, stop: Int) -> [Trip] {
        Handler.load()

        return Departures.getDepartures(date: date, time: time, stop: stop)
    }

    static func getDepartures(date: String, time: String, stops: [ApiBusStop]) -> [Trip] {
        Handler.load()

        return Departures.getDepartures(date: date, time: time, stops: stops)
    }

    static func getDepartures(stop: Int) -> [Trip] {
        let date = DATE.string(from: Date())
        let time = TIME.string(from: Date())

        return getDepartures(date: date, time: time, stop: stop)
    }

    static func getMergedDepartures(group: Int) -> [Trip] {
        var stops = [ApiBusStop]()

        for busStop in BusStopRealmHelper.getBusStopsFromGroup(group: group) {
            stops.append(ApiBusStop(id: busStop.id))
        }

        let date = DATE.string(from: Date())
        let time = TIME.string(from: Date())

        return API.getDepartures(date: date, time: time, stops: stops)
    }

    /*@NonNull
    public static List<String> getPassingLines(Context context, int family) {
    Preconditions.checkNotNull(context, "getPassingLines() context == null");
    
    Handler.load(context);
    
    Collection<BusStop> busStops = BusStopRealmHelper.getBusStopsFromFamily(family);
    x
    List<String> lines = new ArrayList<>();
    for (Map.Entry<Integer, Map<Integer, List<BusStop>>> line : Paths.getPaths().entrySet()) {
    for (Map.Entry<Integer, List<BusStop>> variant : line.getValue().entrySet()) {
    if (!Collections.disjoint(variant.getValue(), busStops)) {
    lines.add(Lines.lidToName(line.getKey()));
    break;
    }
    }
    }
    
    Collections.sort(lines, (lhs, rhs) -> 
     Integer.parseInt(B.matcher(A.matcher(lhs).replaceAll(Matcher.quoteReplacement("")))
     .replaceAll(Matcher.quoteReplacement(""))) -
    Integer.parseInt(B.matcher(A.matcher(rhs)
     .replaceAll(Matcher.quoteReplacement(""))).replaceAll(Matcher.quoteReplacement(""))));
    
    for (int i = 0; i < lines.size(); i++) {
    String line = lines.get(i);
    if (line.contains("A")) lines.set(i, line.replace("A", "B"));
    if (line.contains("B")) lines.set(i, line.replace("B", "A"));
    }
    
    return lines;
    }
    
    @NonNull
    public static List<Integer> getPassingLinesIds(Context context, int family) {
    Preconditions.checkNotNull(context, "getPassingLinesIds() context == null");
    
    Handler.load(context);
    
    Collection<BusStop> busStops = BusStopRealmHelper.getBusStopsFromFamily(family);
    
    List<Integer> lines = new ArrayList<>();
    for (Map.Entry<Integer, Map<Integer, List<BusStop>>> line : Paths.getPaths().entrySet()) {
        for (Map.Entry<Integer, List<BusStop>> variant : line.getValue().entrySet()) {
            if (!Collections.disjoint(variant.getValue(), busStops)) {
                lines.add(line.getKey());
                break;
            }
        }
    }
    
    List<Integer> allLines = new ArrayList<>();
    for (int line : Lines.allLines) {
    allLines.add(line);
    }
    
    Collections.sort(lines, (lhs, rhs) -> allLines.indexOf(lhs) - allLines.indexOf(rhs));
    
    return lines;
    }
    
    @NonNull
    public static Iterable<Integer> getBusStopsOfLines(Context context, Iterable<Integer> lines) {
    Preconditions.checkNotNull(context, "getBusStopsOfLines() context == null");
    
    Handler.load(context);
    
    Collection<Integer> busStops = new HashSet<>();
    for (Integer line : lines) {
    for (int i = 0; i < Paths.VARIANTS.get(line); i++) {
    List<BusStop> path = Paths.getPath(line, i + 1);
    for (int j = 0; j < path.size(); j++) {
    busStops.add(path.get(j).getId());
    }
    }
    }
    
    return busStops;
    }*/

    static func getNextTrip(lines: [Int], stop: Int, time: Int) -> PlannedDeparture? {
        Handler.load()

        let date = DATE.string(from: Date())
        let time = ApiUtils.getTime(seconds: time)

        Log.info("DATE: \(date)")
        Log.info("TIME: \(time)")

        let departures: [Trip] = Departures.getDepartures(date: date, time: time, stop: stop)

        for trip in departures {
            if lines.contains(trip.getLine()) {
                return PlannedDeparture(
                    line: trip.getLine(),
                    time: trip.getSecondsAtStation(busStopId: stop),
                    trip: trip.getTrip()
                )
            }
        }

        return nil
    }

    static func todayExists() -> Bool {
        Handler.load()
        return CompanyCalendar.getDayType(date: DATE.string(from: Date())) != -1
    }
}
