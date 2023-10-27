//
//  ModeView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 24.02.23.
//

import SwiftUI

struct Item {
    let id = UUID()
    let mode: AppMode
    let title: String
    let color: Color
}

struct ModeView: View {
    @State private var showingAlert = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var speechSynthesizer: SpeechSynthesizer
    
    let items = [
        Item(mode: .manualLabeling, title: "Manual", color: .mint),
        Item(mode: .semiAutomaticLabeling, title: "Semi-automatic", color: .blue),
        Item(mode: .monitoring, title: "Eye-rubbing", color: .red),
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing:1) {
                ForEach(items, id: \.id) { item in
                    NavigationLink(destination: SessionPagingView(mode: item.mode)) {
                        ModeButton(mode: item.mode, color: item.color, title: item.title)
                    }
                    .disabled(((item.mode == .semiAutomaticLabeling) || (item.mode == .monitoring)) && !dataManager.allowPrediction)
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        WKInterfaceDevice.current().play(.click)
                        if !(item.mode == .manualLabeling) && !(dataManager.allowPrediction) {
                            showingAlert = true
                        }
                    })
                }
                .scrollTransition(.interactive, axis: .vertical) {
                    view, phase in
                    view.scaleEffect(x: phase.isIdentity ? 1 : 0.85)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .navigationTitle("EyeRub")
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Mode Not Available"),
                  message: Text("This mode is available only when the digital crown is on the right side."),
                  dismissButton: .default(Text("Got it!"), action: { dismiss() })
            )
        }
        .onAppear {
            speechSynthesizer.speakMessage(message: "Choose a mode to start.")
        }
    }
    
}

//#Preview {
//    ModeView()
//}
