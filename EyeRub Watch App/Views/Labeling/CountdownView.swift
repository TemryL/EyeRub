//
//  CountdownView.swift
//  EyeRub Watch App
//
//  Created by Tom MERY on 03.02.23.
//

import SwiftUI
import Foundation
import WatchKit

struct CountdownView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var timeRemaining = 2
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("\(timeRemaining)")
            .foregroundColor(.brown)
            .font(.system(size:100, design: .rounded))
            .onReceive(timer) { time in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
                if timeRemaining == 0 {
                    WKInterfaceDevice.current().play(.start)
                    timer.upstream.connect().cancel()
                    dataManager.startUpdates()
                }
            }
            .onReceive(dataManager.$isDataArrayFull) { isDataArrayFull in
                if isDataArrayFull {
                    WKInterfaceDevice.current().play(.stop)
                    dataManager.sendLabeledActionToIphone(label:dataManager.label)
                    dataManager.showingCountdownView = false
                }
            }
            .navigationBarBackButtonHidden(true)
    }
}

struct CountdownView_Previews: PreviewProvider {
    static var previews: some View {
        CountdownView().environmentObject(DataManager())
    }
}
