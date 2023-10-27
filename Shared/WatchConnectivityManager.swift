//
//  WatchConnectivityManager.swift
//  EyeRub
//
//  Created by Tom MERY on 28.12.22.
//

import Foundation
import WatchConnectivity

struct Message: Identifiable {
    let id: UUID = UUID()
    let content: [String: Any]
}

final class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared: WatchConnectivityManager = WatchConnectivityManager()
    @Published var message: Message? = nil
    @Published var applicationContext: String = ""
    @Published var isReachable = false
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func send(message: [String : Any]) -> Void {
        guard WCSession.default.activationState == .activated else {
            print("WCSession not activated")
          return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            print("Watch App not installed")
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            print("Companion App not installed")
            return
        }
        #endif
        
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }
    
    func sendApplicationContext(messageToSend: String) {
        if WCSession.default.activationState == .activated {
            let message = ["message": messageToSend]
            do {
                try WCSession.default.updateApplicationContext(message)
            } catch {
                print("Error updating application context: \(error.localizedDescription)")
            }
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.message = Message(content: message)
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let receivedMessage = applicationContext["message"] as? String {
            DispatchQueue.main.async {
                self.applicationContext = receivedMessage
            }
        }
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        switch activationState {
        case .notActivated:
            DispatchQueue.main.async {
                self.isReachable = false
            }
        case .inactive:
            DispatchQueue.main.async {
                self.isReachable = false
            }
        case .activated:
            DispatchQueue.main.async {
                self.isReachable = true
            }
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            DispatchQueue.main.async {
                self.isReachable = true
            }
        } else {
            DispatchQueue.main.async {
                self.isReachable = false
            }
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
