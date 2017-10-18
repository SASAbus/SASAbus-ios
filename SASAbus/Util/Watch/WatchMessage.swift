import Foundation

enum WatchMessage: String {
    
    case recentBusStops = "MESSAGE_RECENT_BUS_STOPS"
    case recentBusStopsResponse = "MESSAGE_RECENT_BUS_STOPS_RESPONSE"
    
    case favoriteBusStops = "MESSAGE_FAVORITE_BUS_STOPS"
    case favoriteBusStopsResponse = "MESSAGE_FAVORITE_BUS_STOPS_RESPONSE"
    
    case nearbyBusStops = "MESSAGE_NEARBY_BUS_STOPS"
    case nearbyBusStopsResponse = "MESSAGE_NEARBY_BUS_STOPS_RESPONSE"
    
    case calculateDepartures = "MESSAGE_CALCULATE_DEPARTURES"
    case calculateDeparturesResponse = "MESSAGE_CALCULATE_DEPARTURES_RESPONSE"
    
    case setBusStopFavorite = "MESSAGE_SET_BUS_STOP_FAVORITE"
}
