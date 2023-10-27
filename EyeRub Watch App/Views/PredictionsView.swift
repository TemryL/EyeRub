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
            return Color("veryLightBlue")
        case "N/A":
            return Color("veryLightBlue")
        case "Eye rubbing":
            return Color.red
        case "Face touching":
            return Color("veryLightBlue")
        case "Teeth brushing":
            return Color("veryLightBlue")
        default:
            return Color("veryLightBlue")
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
