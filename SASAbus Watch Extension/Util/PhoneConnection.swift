//
//  WatchConnection.swift
//  SASAbus
//
//  Created by Alex Lardschneider on 28/09/2017.
//  Copyright © 2017 SASA AG. All rights reserved.
//

import Foundation
import WatchConnectivity

class PhoneConnection: NSObject, WCSessionDelegate {
    
    var session: WCSession!
    
    var listeners = [PhoneMessageListener]()
    
    public static var standard = PhoneConnection()
    
    
    override init() {
        super.init()
    }
    
    
    func connect() {
        if WCSession.isSupported() {
            Log.warning("WatchKit Session is available")
            
            session = WCSession.default()
            session.delegate = self
            session.activate()
        } else {
            Log.warning("WatchKit Session is not available")
        }
    }
    
    func isConnected() -> Bool {
        return session != nil && session.activationState == .activated
    }
    
    func sendMessage(message: [String: Any]) {
        guard isConnected() else {
            fatalError("WatchKit Session not connected")
        }
        
        Log.info("Sending message: '\(message)'")
        
        session.sendMessage(message, replyHandler: { reply in
            Log.warning("WatchKit Session Got reply: '\(reply)'")
            
            guard let type = reply["type"] as? String else {
                Log.error("WatchKit Session message type is not of type 'String'")
                return
            }
            
            guard let messageType = WatchMessage(rawValue: type) else {
                Log.error("WatchKit Session unknown message type: '\(type)'")
                return
            }
            
            guard !self.listeners.isEmpty else {
                Log.error("WatchKit Session no listeners available")
                return
            }
            
            guard let data = reply["data"] as? String else {
                Log.error("WatchKit Session message data is not of type 'String'")
                return
            }
            
            for listener in self.listeners {
                listener.didReceiveMessage(type: messageType, data: data)
            }
        }, errorHandler: { error in
            Log.warning("Got error: '\(error)'")
        })
    }

    
    func addListener(_ listener: PhoneMessageListener) {
        listeners.append(listener)
    }
    
    func removeListener(_ listener: PhoneMessageListener) {
        listeners = listeners.filter() { $0 !== listener }
    }
}

extension PhoneConnection {
    
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
    }
}

protocol PhoneMessageListener: class {
    
    func didReceiveMessage(type: WatchMessage, data: String)
}
