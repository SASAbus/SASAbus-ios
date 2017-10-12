import Foundation
import ObjectMapper

class DepartureMonitor {

    private var busStops = [VdvBusStop]()
    private var lineFilter = [Int]()

    private var time = ApiTime.now()
    private var past = 300
    private var maxElements = Int.max
    

    func atBusStop(busStop: Int) -> DepartureMonitor {
        busStops.append(VdvBusStop(id: busStop))
        return self
    }

    func atBusStops(busStops: [Int]) -> DepartureMonitor {
        for busStop in busStops {
            self.busStops.append(VdvBusStop(id: busStop))
        }

        return self
    }

    
    func atBusStopFamily(family: Int) -> DepartureMonitor {
        busStops.append(contentsOf: BusStopRealmHelper.getBusStopsFromFamily(family: family))

        return self
    }

    func atBusStopFamilies(families: [Int]) -> DepartureMonitor {
        for busStopFamily in families {
            busStops.append(contentsOf: BusStopRealmHelper.getBusStopsFromFamily(family: busStopFamily))
        }

        return self
    }

    
    func at(date: Date) -> DepartureMonitor {
        return at(millis: date.millis())
    }

    private func at(millis: Int64) -> DepartureMonitor {
        time = ApiTime.addOffset(millis: millis)

        return self
    }

    
    func filterLine(line: Int) -> DepartureMonitor {
        lineFilter.append(line)

        return self
    }

    func filterLines(lines: [Int]) -> DepartureMonitor {
        lineFilter.append(contentsOf: lines)

        return self
    }

    
    func maxElements(maxElements: Int) -> DepartureMonitor {
        self.maxElements = maxElements

        return self
    }

    func includePastDepartures(seconds: Int) -> DepartureMonitor {
        past = seconds

        return self
    }

    
    func collect() -> [VdvDeparture] {
        let date = Date(timeIntervalSince1970: Double(time / 1000))

        let isToday = Calendar.current.isDateInToday(date)

        if !isToday {
            do {
                try VdvTrips.loadTrips(day: VdvCalendar.date(date))
            } catch {
                Log.error("Unable to load departures: \(error)")
                return []
            }
        }

        var departures = [VdvDeparture]()
        var lines = [Int]()
        let busStopFamilies = busStops.map {
            BusStopRealmHelper.getBusStopGroup(id: $0.id)
        }

        for busStopFamily in busStopFamilies {
            lines.append(contentsOf: Api.getPassingLines(group: busStopFamily))
        }

        if !lineFilter.isEmpty {
            lines = lines.filter {
                lineFilter.contains($0)
            }
        }

        time /= 1000
        time %= 86400

        let list = isToday ? VdvTrips.ofSelectedDay() : VdvTrips.ofOtherDay()

        for trip in list {
            if lines.contains(trip.lineId) {
                var path = trip.calcPath()

                if !Set(path).isDisjoint(with: busStops) {
                    for busStop in busStops {
                        if let index = path.index(of: busStop), index != path.count - 1 {
                            path = trip.calcTimedPath()

                            if path[index].departure > Int(time - past) {
                                departures.append(VdvDeparture(
                                        lineId: trip.lineId,
                                        time: path[index].departure,
                                        destination: path.last!,
                                        tripId: trip.tripId
                                ))
                            }
                        }
                    }
                }
            }
        }

        departures.sort()

        if maxElements != 0 {
            let end: Int = (maxElements > departures.count) ? departures.count : maxElements
            departures = Array(departures[0..<end])
        }

        return departures
    }

    static func calculateForWatch(_ group: Int, replyHandler: @escaping ([String : Any]) -> Void, addToFavorites: Bool = true) {
        if addToFavorites {
            UserRealmHelper.addRecentDeparture(group: group)
        }
        
        let monitor = DepartureMonitor()
            .atBusStopFamily(family: group)
            .maxElements(maxElements: 20)
            .at(date: Date())
        
        DispatchQueue.global(qos: .background).async {
            let departures = monitor.collect()
            
            let mapped: [Departure] = departures.map {
                $0.asDeparture(busStopId: 0)
            }
            
            var message = [String: Any]()
            message["type"] = WatchMessage.calculateDeparturesResponse.rawValue
            message["data"] = Mapper().toJSONString(mapped, prettyPrint: false)
            message["is_favorite"] = UserRealmHelper.hasFavoriteBusStop(group: group)
            
            replyHandler(message)
        }
    }
}
