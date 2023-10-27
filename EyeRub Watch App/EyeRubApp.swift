//
//  EyeRub.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 10.12.22.
//

import SwiftUI

@main
struct EyeRub_Watch_App: App {
    @StateObject private var dataManager = DataManager()
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var speechSynthesizer = SpeechSynthesizer()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartView()
            }
            .sheet(isPresented: $workoutManager.showingSummaryView) {
                SummaryView()
            }
            .sheet(isPresented: $dataManager.showingLabelsView) {
                LabelsView()
            }
            .sheet(isPresented: $dataManager.showingCountdownView) {
                CountdownView()
            }
            .environmentObject(dataManager)
            .environmentObject(workoutManager)
            .environmentObject(speechSynthesizer)
        }
    }
}
