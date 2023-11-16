//
//  LabelsView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 10.12.22.
//

import SwiftUI

struct LabelsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var hapticTimer: Timer?
        
    let labels: [String] = ["Nothing",
                            "Eye rubbing",
                            "Eye touching",
                            "Glasses readjusting",
                            "Eating",
                            "Make up",
                            "Hair combing",
                            "Skin scratching",
                            "Teeth brushing"]
    
    let colorEncoder: [String:Color] = ["Nothing": .green,
                                        "Eye rubbing": .red,
                                        "Eye touching": .orange,
                                        "Glasses readjusting": .orange,
                                        "Eating": .orange,
                                        "Make up": .orange,
                                        "Hair combing": .purple,
                                        "Skin scratching": .purple,
                                        "Teeth brushing": .blue]
    
    var body: some View {
        VStack {
            if dataManager.appMode == .semiAutomaticLabeling {
                Button("I don't know") {
                    saveLabel(label: "I don't know")
                }
                .buttonStyle(CustomButtonStyle())
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }

            List(labels, id: \.self) { label in
                Button(action: {
                    saveLabel(label: label)
                }) {
                    HStack {
                        Image(systemName: "waveform.path")
                            .foregroundColor(colorEncoder[label])
                        Text(label)
                    }
                }
                .buttonStyle(CustomButtonStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .listStyle(.carousel)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear(perform: startHapticTimer)
        .onDisappear(perform: stopHapticTimer)
    }
    
    func saveLabel(label: String) {
        if dataManager.appMode == .manualLabeling {
            dataManager.label = label
            dataManager.showingCountdownView = true
        }
        else if dataManager.appMode == .semiAutomaticLabeling {
            if label != "I don't know" {
                dataManager.sendLabeledActionToIphone(label: label)
            }
            dataManager.showingLabelsView = false
            dataManager.resume()
            workoutManager.resume()
        }
    }
    
    func startHapticTimer() {
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            if dataManager.appMode == .semiAutomaticLabeling {
                triggerHapticFeedback()
            }
        }
    }

    func stopHapticTimer() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    func triggerHapticFeedback() {
        WKInterfaceDevice.current().play(.failure)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
            .foregroundColor(configuration.isPressed ? .gray : .primary)
    }
}

struct LabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LabelsView()
            .environmentObject(DataManager())
            .environmentObject(WorkoutManager())
    }
}
