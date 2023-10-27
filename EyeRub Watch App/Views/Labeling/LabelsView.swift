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
    
    let labels: [String] = ["Eye rubbing",
                            "Skin scratching",
                            "Hair combing",
                            "Nothing",
                            "Eye touching",
                            "Glasses readjusting",
                            "Eating",
                            "Make up",
                            "Teeth brushing"]
    
    var body: some View {
        List(labels, id: \.self) { label in
            Button("\(label)") {
                saveLabel(label: label)
            }
            .fontWeight(.semibold)
            .font(.system(.caption, design: .rounded))
        }
        .listStyle(.carousel)
        .navigationBarBackButtonHidden(true)
    }
    
    func saveLabel(label: String) {
        if dataManager.appMode == .manualLabeling {
            dataManager.label = label
            dataManager.showingCountdownView = true
        }
        else if dataManager.appMode == .semiAutomaticLabeling {
            dataManager.sendLabeledActionToIphone(label: label)
            dataManager.showingLabelsView = false
            dataManager.resume()
            workoutManager.resume()
        }
    }
}

struct LabelsView_Previews: PreviewProvider {
    static var previews: some View {
        LabelsView()
            .environmentObject(DataManager())
            .environmentObject(WorkoutManager())
    }
}
