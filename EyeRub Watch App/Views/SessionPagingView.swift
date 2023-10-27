//
//  SessionPagingView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 10.12.22.
//

import SwiftUI
import WatchKit
import AVFoundation

struct SessionPagingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.isLuminanceReduced) var isLuminanceReduced
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var dataManager: DataManager
    @State private var selection: Tab = .central
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    static let speechSynthesizer = AVSpeechSynthesizer()
    var mode: AppMode
    var icon: Image
    var color: Color
    
    init(mode: AppMode) {
        self.mode = mode
        switch mode {
        case .manualLabeling:
            self.icon = Image("LabelingIcon")
            self.color = .mint
        case .semiAutomaticLabeling:
            self.icon = Image("LabelingIcon")
            self.color = .blue
        case .monitoring:
            self.icon = Image("MonitoringIcon")
            self.color = .red
        case .notSet:
            self.icon = Image("LabelingIcon")
            self.color = .white
        }
    }
    
    enum Tab {
        case central, currentSummary
    }

    var body: some View {
        TabView(selection: $selection) {
            TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date())) { context in
                VStack {
                    if mode == .manualLabeling {
                        LabelsView().tag(Tab.central)
                    }
                    else {
                        PredictionsView().tag(Tab.central)
                    }
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        icon
                            .foregroundColor(color)
                            .symbolEffect(.variableColor)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        if mode == .manualLabeling {
                            Button {
                                WKInterfaceDevice.current().play(.click)
                                workoutManager.endWorkout()
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .foregroundColor(.red)
                        }
                        else {
                            Text(workoutManager.running ? "Running" : "Paused")
                        }
                    }

                    if mode != .manualLabeling {
                        ToolbarItemGroup(placement: .bottomBar) {
                            Button {
                                WKInterfaceDevice.current().play(.click)
                                workoutManager.endWorkout()
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .foregroundColor(.red)
                            
                            ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime ?? 0, showSubseconds: context.cadence == .live)
                                .font(.system(.headline, design: .rounded).monospacedDigit().lowercaseSmallCaps())
                                .controlSize(.large)
                                .foregroundColor(Color("veryLightBlue"))
                            
                            Button {
                                WKInterfaceDevice.current().play(.click)
                                dataManager.togglePause()
                                workoutManager.togglePause()
                            } label: {
                                Image(systemName: workoutManager.running ? "pause" : "play")
                            }
                            .disabled(mode == .manualLabeling)
                            .foregroundColor(Color("veryLightBlue"))
                        }
                    }
                }
            }
            
            if (mode == .monitoring) {
//                MonitoringSummaryView().tag(Tab.currentSummary)
            }
            else {
                LabelingSummaryView().tag(Tab.currentSummary)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: workoutManager.running) { _ in
            displayCentralView()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminanceReduced ? .never : .automatic))
        .onChange(of: isLuminanceReduced) { _ in
            displayCentralView()
        }
        .onChange(of: workoutManager.showingSummaryView) { showingSummaryView in
            if showingSummaryView {
                dismiss()
            }
        }
//        .onReceive(timer) { time in
//            timer.upstream.connect().cancel()
//            displayCentralView()
//        }
        .onReceive(dataManager.$predictedLabel){
            predictedLabel in alertUser(label: predictedLabel)
        }
        .onAppear(){
            startSession(mode: mode)
        }
    }
    
    func startSession(mode: AppMode) {
        dataManager.initSession(mode: mode)
        workoutManager.startWorkout()
        
        if (mode == .semiAutomaticLabeling) || (mode == .monitoring) {
            if mode == .monitoring {
                dataManager.monitoredLabel = "Eye rubbing"
            }
            dataManager.startUpdates()
        }
    }
        
    private func displayCentralView() {
        withAnimation {
            selection = .central
        }
    }
    
    func alertUser(label: String) -> Void {
        if mode == .monitoring {
            if (dataManager.monitoredLabel == "All" && label != "Nothing" && label != "N/A") {
                speakMessage(message: label)
            }
            else if (label == dataManager.monitoredLabel) {
                speakMessage(message: label)
            }
        }
        else {
            if (label != "Nothing") && (label != "N/A") {
                workoutManager.pause()
                speakMessage(message: "Face Touching")
    //            WKInterfaceDevice.current().play(.failure)
                dataManager.showingLabelsView = true
            }
        }
    }
    
    func speakMessage(message: String) {
        let speechUtterance = AVSpeechUtterance(string: message)
        speechUtterance.rate = 0.5
        
        let samanthaVoiceID = "com.apple.voice.compact.en-US.Samantha"
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()

        if availableVoices.first(where: { $0.identifier == samanthaVoiceID }) != nil {
            let samanthaVoice = AVSpeechSynthesisVoice(identifier: "com.apple.voice.compact.en-US.Samantha")
            speechUtterance.voice = samanthaVoice
        }
        
        SessionPagingView.speechSynthesizer.speak(speechUtterance)
    }
    
}

//struct SessionPagingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionPagingView()
//            .environmentObject(WorkoutManager())
//            .environmentObject(DataManager())
//    }
//}


private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date

    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: self.startDate, by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
    }
}
