//
//  ModeButton.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 14.10.23.
//

import SwiftUI

struct ModeButton: View {
    var mode: AppMode
    var icon: Image
    var color: Color
    var title: String
    var height = 120.0
    
    init(mode: AppMode, color:Color, title: String) {
        self.mode = mode
        self.color = color
        self.title = title
        switch mode {
        case .manualLabeling:
            self.icon = Image("LabelingIcon")
        case .semiAutomaticLabeling:
            self.icon = Image("LabelingIcon")
        case .monitoring:
            self.icon = Image("MonitoringIcon")
        case .notSet:
            self.icon = Image("LabelingIcon")
        }
        
    }
    
    let darkGray = Color(white: 0.2)
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .fill(darkGray)
                        .cornerRadius(25)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            icon
                                .foregroundColor(color)
                                .symbolEffect(.variableColor)
                                .font(.system(size: 30))
                            
                            Spacer()
                            
                            if (mode == .manualLabeling) || (mode == .semiAutomaticLabeling) {
                                VStack(alignment: .leading) {
                                    Text("Labeling")
                                        .font(.headline)
                                    
                                    Text(title)
                                        .foregroundColor(color)
                                        .bold()
                                        .font(.system(.headline, design: .rounded).smallCaps())
                                        
                                }
                                .padding(.bottom)

                            } else {
                                VStack(alignment: .leading) {
                                    Text("Monitoring")
                                        .font(.headline)
                                    
                                    Text(title)
                                        .foregroundColor(color)
                                        .bold()
                                        .font(.system(.headline, design: .rounded).smallCaps())
                                        
                                }
                                .padding(.bottom)
                            }
                        }
                        .padding(10)

                        Spacer()
                        
                        
                        NavigationLink(destination: ModeInfoView(mode: mode, color: color)) {
                            Image(systemName: "info.circle")
                                .resizable()
                                .foregroundColor(color)
                                .frame(width: 20, height: 20)
                        }
                        .frame(maxWidth: 20, maxHeight: 20)
                        .buttonStyle(PlainButtonStyle())
                        .offset(x: 0, y: 0.55*(-height/2))
                        .padding(15)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: height)
        }
        .frame(height: height)
    }
}

//struct ModeButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ModeButton(mode: .monitoring, color: .orange, title: "Eye-rubbing")
//    }
//}
