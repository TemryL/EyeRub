//
//  LabelingSummaryView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 16.02.23.
//

import SwiftUI

struct LabelingSummaryView: View {
    @EnvironmentObject var dataManger: DataManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                SummaryMetricView(title: "Eye rubbing",
                                  value: String(dataManger.summaryCount["Eye rubbing"]!))
                .foregroundStyle(.red)
                
                SummaryMetricView(title: "Eye touching",
                                  value: String(dataManger.summaryCount["Eye touching"]!)
                )
                .foregroundStyle(.orange)
                
                SummaryMetricView(title: "Glasses readjusting",
                                  value: String(dataManger.summaryCount["Glasses readjusting"]!)
                )
                .foregroundStyle(.orange)
                
                SummaryMetricView(title: "Eating",
                                  value: String(dataManger.summaryCount["Eating"]!)
                )
                .foregroundStyle(.orange)
                                
                SummaryMetricView(title: "Make up",
                                  value: String(dataManger.summaryCount["Make up"]!)
                )
                .foregroundStyle(.orange)
                
                SummaryMetricView(title: "Skin scratching",
                                  value: String(dataManger.summaryCount["Skin scratching"]!)
                )
                .foregroundStyle(.purple)
                
                SummaryMetricView(title: "Hair combing",
                                  value: String(dataManger.summaryCount["Hair combing"]!)
                )
                .foregroundStyle(.purple)
                
                SummaryMetricView(title: "Teeth brushing",
                                  value: String(dataManger.summaryCount["Teeth brushing"]!)
                )
                .foregroundStyle(.blue)
                
                SummaryMetricView(title: "Nothing",
                                  value: String(dataManger.summaryCount["Nothing"]!)
                )
                .foregroundStyle(.green)
            }
            .scenePadding()
        }
    }
}

//struct CurrentSummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        LabelingSummaryView().environmentObject(DataManager())
//    }
//}
