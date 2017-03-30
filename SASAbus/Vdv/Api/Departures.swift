import Foundation

class Departures {

    static func getDepartures(date: String, time: String, stop: Int) -> [Trip] {
        let seconds: Int = ApiUtils.getSeconds(time: time)
        var trips = [Trip]()
        
        let courses: [[Int]] = Trips.getCoursesPassingAt(station: ApiBusStop(id: stop))
    
        // finds all the lines/variants passing at the stop
        for course in courses {
            let dayTrips = Trips.getTrips(day: CompanyCalendar.getDayType(date: date),
                                          line: course[0], variant: course[1])
            
            for trip in dayTrips {
                if trip.getSecondsAtStation(busStopId: stop) >= seconds {
                    trips.append(trip)
                }
            }
        }
        
        trips.sort(by: { $0.getSecondsAtUserStop() < $1.getSecondsAtUserStop() })
    
        return trips
    }
    
    static func getDepartures(date: String, time: String, stops: [ApiBusStop]) -> [Trip] {
        let seconds = ApiUtils.getSeconds(time: time)
        var trips = [Trip]()
    
        // finds all the lines/variants passing at the stop
        for stop in stops {
            let id = stop.getId()
            let courses: [[Int]] = Trips.getCoursesPassingAt(station: stop)
            
            for course in courses {
                let dayTrips = Trips.getTrips(day: CompanyCalendar.getDayType(date: date),
                                              line: course[0], variant: course[1])
                
                for trip in dayTrips {
                    if trip.getSecondsAtStation(busStopId: id) >= seconds {
                        trips.append(trip)
                    }
                }
            }
        }
        
        trips.sort(by: { $0.getSecondsAtUserStop() < $1.getSecondsAtUserStop() })
    
        return trips
    }
}
