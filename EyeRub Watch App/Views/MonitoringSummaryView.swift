//
//  MonitoringSummaryView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 16.10.2023.
//

import SwiftUI

struct MonitoringSummaryView: View {
    @EnvironmentObject var dataManager: DataManager
    let colors: [String: Color] = ["Eye Rubbing": .red,
                                   "Face Touching": .orange,
                                   "Teeth Brushing": .blue]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(dataManager.monitoredSamples) { sample in
                    MonitorSummaryView(date: sample.date,
                                       label: sample.label)
                    .foregroundStyle(colors[sample.label, default: .purple])
                }
            }
            .scenePadding()
        }
    }}

struct MonitorSummaryView: View {
    var date: String
    var label: String

    var body: some View {
        Text(date)
            .foregroundStyle(.foreground)
            .font(.system(.caption, design: .rounded))
        Text(label)
            .font(.system(.headline, design: .rounded).lowercaseSmallCaps())
        Divider()
    }
}

//#Preview {
//    MonitoringSummaryView()
//}

