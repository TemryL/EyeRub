//
//  PredictionsView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 10.12.22.
//

import SwiftUI

struct PredictionsView: View {
    @EnvironmentObject var dataManager: DataManager

    var predictedLabelColor: Color {
        switch dataManager.predictedLabel {
        case "Nothing":
            return .blue
        case "N/A":
            return .blue
        case "Eye rubbing":
            return Color.red
        case "Face touching":
            return .blue
        case "Teeth brushing":
            return .blue
        default:
            return Color("veryLightBlue")
        }
    }
    
    var body: some View {
        VStack{
            HStack {
                Spacer()
                Text("Threshold: \(Int(100*dataManager.threshold))%")
                    .foregroundColor(Color("veryLightBlue"))
                    .fontWeight(.semibold)
                    .font(.caption2)
            }
            
            Spacer()
            
            Text(dataManager.predictedLabel)
                .foregroundColor(predictedLabelColor)
                .fontWeight(.semibold)
                .font(.system(.title, design: .rounded))
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .lineLimit(2)
            
            Spacer()
            
            Slider(
                value: $dataManager.threshold,
                in: 0.8...1.01,
                step: 0.01
            )
            .focusable()
            .frame(width:0, height: 0)
            .opacity(0)
        }
    }
}

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionsView()
            .environmentObject(DataManager())
    }
}
