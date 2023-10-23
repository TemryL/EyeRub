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
            return Color.brown
        case "N/A":
            return Color.brown
        case "Eye rubbing":
            return Color.red
        case "Face touching":
            return Color.brown
        case "Teeth brushing":
            return Color.brown
        default:
            return Color.brown
        }
    }
    
    var body: some View {
        VStack{
            Text(dataManager.predictedLabel)
                .foregroundColor(predictedLabelColor)
                .fontWeight(.semibold)
                .font(.system(.title, design: .rounded))
                .scaledToFit()
                .minimumScaleFactor(0.5)
                .lineLimit(2)
        }
    }
}

struct PredictionView_Previews: PreviewProvider {
    static var previews: some View {
        PredictionsView()
            .environmentObject(DataManager())
    }
}
