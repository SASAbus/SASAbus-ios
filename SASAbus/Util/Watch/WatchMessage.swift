//
//  WatchMessage.swift
//  SASAbus
//
//  Created by Alex Lardschneider on 28/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import Foundation

enum WatchMessage: String {
    
    case recentBusStops = "MESSAGE_RECENT_BUS_STOPS"
    
    case favoriteBusStops = "MESSAGE_FAVORITE_BUS_STOPS"
    case favoriteBusStopsResponse = "MESSAGE_FAVORITE_BUS_STOPS_RESPONSE"
    
    case nearbyBusStops = "MESSAGE_NEARBY_BUS_STOPS"
    case nearbyBusStopsResponse = "MESSAGE_NEARBY_BUS_STOPS_RESPONSE"
    
    case calculateDepartures = "MESSAGE_CALCULATE_DEPARTURES"
    case calculateDeparturesResponse = "MESSAGE_CALCULATE_DEPARTURES_RESPONSE"
    
    case setBusStopFavorite = "MESSAGE_SET_BUS_STOP_FAVORITE"
}
