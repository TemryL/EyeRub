//
//  StatisticsView.swift
//  EyeRub
//
//  Created by Tom MERY on 12.07.23.
//

import SwiftUI


struct StatisticsView: View {
    var actions: [Action]

    var body: some View {
        VStack {
            HStack {
                Text("Total")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(actions.count)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Divider()
            
            ForEach(statisticsData.sorted(by: { $0.count > $1.count }), id: \.label) { statistic in
                HStack {
                    Text(statistic.label)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(statistic.count)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    private struct Statistic: Identifiable {
        let label: String
        let count: Int
        var id: String { label }
    }

    private var statisticsData: [Statistic] {
        let statistics = Dictionary(grouping: actions, by: { $0.label })
            .map { label, actions in
                Statistic(label: label, count: actions.count)
            }
        return statistics
    }
}
