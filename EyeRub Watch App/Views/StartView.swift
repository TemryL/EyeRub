//
//  StartView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 10.12.22.
//

import SwiftUI
import WatchKit
import AVFoundation
import WatchConnectivity

struct StartView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    
    var body: some View {
        VStack {
            if connectivityManager.isReachable && isAuthenticated {
                ModeView()
            }
            else if connectivityManager.isReachable && !isAuthenticated {
                VStack {
                    Image("IconOrange")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())

                    Text("Please sign in using iPhone")
                        .font(.caption)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding()
                }
                .transition(.scale)
                .animation(.spring())
                .onAppear() {
                    workoutManager.endWorkout()
                    dataManager.reset()
                }
            }
            else {
                ZStack {
                    VStack {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 80))
                            .foregroundColor(.red)

                        Text("iPhone is not reachable")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .transition(.scale)
                    .animation(.spring())
                }
            }
        }
        .onAppear(perform: setEnvironment)
        .onReceive(connectivityManager.$applicationContext){
            message in
            if message == "signedIn" {
                isAuthenticated = true
            } else if message == "notSignedIn" {
                isAuthenticated = false
            }
        }
    }
    
    func setEnvironment() {
        // Send empty message to Iphone to make sure WCSession is activated
        WatchConnectivityManager.shared.send(message: ["":""])
        
        workoutManager.requestAuthorization()

        // Set audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Error setting audio session category: \(error.localizedDescription)")
        }
        
        dataManager.formatUserInfo()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
            .environmentObject(DataManager())
            .environmentObject(WorkoutManager())
    }
}
