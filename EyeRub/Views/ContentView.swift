//
//  ContentView.swift
//  EyeRub
//
//  Created by Tom MERY on 12.07.23.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @ObservedObject var app: RealmSwift.App
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var authentificationController: AuthentificationController
    
    var body: some View {
        if let user = app.currentUser {
            // Setup configuraton so user initially subscribes to their own actions
            let config = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
                let labelingSubscriptionExists = subs.first(named: "user-labeled-actions")
                let monitoringSubscriptionExists = subs.first(named: "user-monitored-actions")
                
                if (labelingSubscriptionExists != nil) && (monitoringSubscriptionExists != nil) {
                    // Existing subscriptions found - do nothing
                    return
                } else {
                    subs.append(QuerySubscription<LabeledAction>(name: "user-labeled-actions") {
                        $0.userID == user.id
                    })
                    subs.append(QuerySubscription<MonitoredAction>(name: "user-monitored-actions") {
                        $0.userID == user.id
                    })
                }
            })
            OpenRealmView(user: user)
                // Store configuration in the environment to be opened in next view
                .environment(\.realmConfiguration, config)
                .onAppear{
                    WatchConnectivityManager.shared.sendApplicationContext(messageToSend: "signedIn")
                }
        } else {
            // If there is no user logged in, show the login view.
            LoginView()
                .environmentObject(authentificationController)
                .onAppear{
                    WatchConnectivityManager.shared.sendApplicationContext(messageToSend: "notSignedIn")
                }
        }
    }
}
