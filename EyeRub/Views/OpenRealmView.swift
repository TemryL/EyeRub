//
//  OpenRealmView.swift
//  EyeRub
//
//  Created by Tom MERY on 12.07.23.
//

import SwiftUI
import RealmSwift

/// Called when login completes. Opens the realm and navigates to the Home screen.
struct OpenRealmView: View {
    @AutoOpen(appId: appConfig.appId, timeout: 2000) var autoOpen
    // We must pass the user, so we can set the user.id when we create Item objects
    @State var user: User
    // Configuration used to open the realm.
    @Environment(\.realmConfiguration) private var config

    var body: some View {
        switch autoOpen {
        case .connecting:
            // Starting the Realm.autoOpen process.
            // Show a progress view.
            ProgressView("Connecting to database...")
            
        case .waitingForUser:
            // Waiting for a user to be logged in before executing
            // Realm.asyncOpen.
            ProgressView("Waiting for user to log in...")
            
        case .open(let realm):
            // The realm has been opened and is ready for use.
            // Show the Home view.
            NavigationStack {
                HomeView(user: user)
                    .environment(\.realm, realm)
                    .navigationTitle("Home")
            }
            .accentColor(Color("lightBlue"))

            
        case .progress(let progress):
            // The realm is currently being downloaded from the server.
            // Show a progress view.
            ProgressView("Downloading data from server...")
            
        case .error(let error):
            // Opening the Realm failed.
            // Show an error view.
            ErrorView(error: error)
        }
    }
}
