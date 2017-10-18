//
//  WatchConnection.swift
//  SASAbus
//
//  Created by Alex Lardschneider on 28/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnection: NSObject, WCSessionDelegate {
    
    var appDelegate: AppDelegate!
    var session: WCSession!
    
    public static var standard = WatchConnection()
    
    
    override init() {
        super.init()
    }
    
    
    func connect(delegate: AppDelegate) {
        if WCSession.isSupported() {
            Log.warning("WatchKit Session is available")
            
            self.appDelegate = delegate
            
            session = WCSession.default()
            session.delegate = self
            session.activate()
        } else {
            Log.warning("WatchKit Session is not available")
        }
    }
}

extension WatchConnection {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        Log.warning("WatchKit Session sessionDidBecomeInactive()")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        Log.warning("WatchKit Session sessionDidDeactivate()")
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Log.warning("WatchKit Session activationDidCompleteWith()")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        Log.warning("WatchKit Session received message: \(message)")
        
        guard let type = message["type"] as? String else {
            Log.error("WatchKit Session message type is not of type 'String'")
            return
        }
        
        guard let messageType = WatchMessage(rawValue: type) else {
            Log.error("WatchKit Session unknown message type: '\(type)'")
            return
        }
        
        switch messageType{
        case .recentBusStops:
            UserRealmHelper.getRecentDepartures(replyHandler: replyHandler)
        case .favoriteBusStops:
            UserRealmHelper.getFavoriteBusStopsForWatch(replyHandler: replyHandler)
        case .calculateDepartures:
            let busStopGroup = message["bus_stop_group"] as! Int
            DepartureMonitor.calculateForWatch(busStopGroup, replyHandler: replyHandler)
        case .setBusStopFavorite:
            let busStop = message["bus_stop"] as! Int
            let isFavorite = message["is_favorite"] as! Bool
            
            if isFavorite {
                UserRealmHelper.addFavoriteBusStop(group: busStop)
            } else {
                UserRealmHelper.removeFavoriteBusStop(group: busStop)
            }
            
            replyHandler([:])
        default:
            break
        }
    }
}
