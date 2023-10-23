//
//  SummaryView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 10.12.22.
//

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var dataManager: DataManager
    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                SummaryMetricView(title: "Total Time",
                                  value: durationFormatter.string(from: workoutManager.elapsedTime ?? 0.0) ?? "")
                .foregroundStyle(.brown)
                
                SummaryMetricView(title: "Total \(dataManager.appMode == .monitoring ? "Monitored":"Labeled") Actions",
                                  value: String(dataManager.numberLabeledActions)
                )
                .foregroundStyle(.green)
                
                Button("Done") {
                    WKInterfaceDevice.current().play(.success)
                    dataManager.reset()
                    workoutManager.showingSummaryView = false
                }
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
            .environmentObject(WorkoutManager())
            .environmentObject(DataManager())
    }
}

struct SummaryMetricView: View {
    var title: String
    var value: String

    var body: some View {
        Text(title)
            .foregroundStyle(.foreground)
        Text(value)
            .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}
