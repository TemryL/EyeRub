//
//  ModeInfoView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 30.09.23.
//

import SwiftUI

struct ModeInfoView: View {
    let mode: AppMode
    let color: Color
    
    var body: some View {
        VStack {
            ScrollView {
                switch mode {
                case .manualLabeling:
                    Text("Manual Labeling")
                        .font(.title3)
                        .foregroundColor(color)
                        .bold()
                        .padding()
                    
                    Group {
                        Text("In this mode, select an action, prepare for 2 seconds, start upon feeling a single haptic, record data for the following 3 seconds, and conclude with two haptics. Your action's duration can vary; the key is to commence within this 3-second window. We encourage diverse starting positions and natural movements.")
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }
                    
                case .semiAutomaticLabeling:
                    Text("Semi-Auto Labeling")
                        .font(.title3)
                        .foregroundColor(color)
                        .bold()
                        .padding()
                    
                    Group {
                        Text("In this mode, a machine learning model predicts every 0.5 seconds. When it detects a hand-face interaction, the watch prompts you to label the previous action. The model may trigger false positives, asking for labels even if you haven't touched your face. In such cases, label it as 'Nothing'.")
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }
                
                case .monitoring:
                    Text("Monitoring")
                        .font(.title3)
                        .foregroundColor(.red)
                        .bold()
                        .padding()
                    
                    Group {
                        Text("In this mode, a machine learning model predicts every 0.5 seconds using the previous 3 seconds' sensor data. Upon detecting an eye-rubbing interaction, the watch provides voice feedback and records the action (including label and timestamp) in the database for analytics.")
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                    }
                case .notSet:
                    Text("Infos not available")
                        .font(.title3)
                        .bold()
                        .padding()

                }
            }
        }
        .navigationTitle("Info")
    }
}


struct ModeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ModeInfoView(mode: .manualLabeling, color: .green)
    }
}
