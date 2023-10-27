//
//  HomeView.swift
//  EyeRub
//
//  Created by Tom MERY on 09.12.22.
//

import SwiftUI
import RealmSwift


struct HomeView: View {
    @State var user: User
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    @ObservedResults(LabeledAction.self, sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: false)) var labeledActions
    @ObservedResults(MonitoredAction.self, sortDescriptor: SortDescriptor(keyPath: "timestamp", ascending: false)) var monitoredActions
    @Environment(\.realm) private var realm
    @State var showProgressView = false
    
    var body: some View {
        if showProgressView {
            ProgressView()
        }
        else {
            TabView {
                VStack {
                    if labeledActions.count == 0 {
                        Text("No data available...\nStart collecting data with your Apple Watch.")
                            .padding()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                    } else {
                        VStack {
                            List {
                                Section("Global Statistics") {
                                    StatisticsView(actions: Array(labeledActions))
                                }
                                
                                Section("Daily Sessions") {
                                    ForEach(groupedLabeledActions, id: \.0) { date, actionsForDate in
                                        NavigationLink(destination: DailySummaryView(actions: actionsForDate).environment(\.realm, realm)){
                                            Text(dateFormatter.string(from: date))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                }
                .navigationTitle("Labeled Actions")
                .tabItem {
                    VStack {
                        Text("Labeling")
                        Image("LabelingIcon")
                    }
                }
                
                VStack {
                    if monitoredActions.count == 0 {
                        Text("No data available...\nStart collecting data with your Apple Watch.")
                            .padding()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                    } else {
                        VStack {
                            List {
                                Section("Global Statistics") {
                                    StatisticsView(actions: Array(monitoredActions))
                                }
                                
                                Section("Daily Sessions") {
                                    ForEach(groupedMonitoredActions, id: \.0) { date, actionsForDate in
                                        NavigationLink(destination: DailySummaryView(actions: actionsForDate).environment(\.realm, realm)){
                                            Text(dateFormatter.string(from: date))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Monitored Actions")
                .tabItem {
                    VStack {
                        Text("Monitoring")
                        Image("MonitoringIcon")
                    }
                }
            }
            .accentColor(Color("lightBlue"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    DeleteAccountButton(onDeleteAccount: deleteAllActions).environment(\.realm, realm)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    LogoutButton().environment(\.realm, realm)
                        .onTapGesture {
                            showProgressView = true
                        }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("veryLightBlue"))
            .onReceive(connectivityManager.$message){
                message in
                if let message = message {
                    if let type = message.content["dataType"] {
                        let dataType = type as! String
                        if dataType == "labeledAction" {
                            addLabeledAction(message:message)
                        }
                        else if dataType == "monitoredAction" {
                            addMonitoredAction(message:message)
                        }
                    }
                }
            }
        }
    }
    
    private var groupedLabeledActions: [(Date, [LabeledAction])] {
        let grouped = Dictionary(grouping: labeledActions) { action in
            Calendar.current.startOfDay(for: action.timestamp)
        }
        return grouped.sorted(by: { $0.key > $1.key })
    }
    
    private var groupedMonitoredActions: [(Date, [MonitoredAction])] {
        let grouped = Dictionary(grouping: monitoredActions) { action in
            Calendar.current.startOfDay(for: action.timestamp)
        }
        return grouped.sorted(by: { $0.key > $1.key })
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    func addLabeledAction(message: Message) {
        let wristLocation = message.content["wristLocation"] as! String
        let crownOrientation = message.content["crownOrientation"] as! String
        let label = message.content["label"] as! String
        let labelingMode = message.content["labelingMode"] as! String
        let sensorDataArrays = message.content["sensorDataArrays"] as! [String: [Float]]
        
        let action = LabeledAction(userID: user.id,
                                   wristLocation: wristLocation,
                                   crownOrientation: crownOrientation,
                                   label: label,
                                   labelingMode: labelingMode,
                                   sensorDataArrays: sensorDataArrays)

        $labeledActions.append(action)
    }
    
    func addMonitoredAction(message: Message) {
        let wristLocation = message.content["wristLocation"] as! String
        let crownOrientation = message.content["crownOrientation"] as! String
        let label = message.content["label"] as! String

        let action = MonitoredAction(userID: user.id,
                                     wristLocation: wristLocation,
                                     crownOrientation: crownOrientation,
                                     label: label)

        $monitoredActions.append(action)
    }
    
    func deleteAllActions() {
        showProgressView = true
        do {
            for action in labeledActions {
                let ID = action._id
                if let action = try! realm.object(ofType: LabeledAction.self, forPrimaryKey: ID) {
                    try realm.write {
                        realm.delete(action)
                    }
                }
            }
            for action in monitoredActions {
                let ID = action._id
                if let action = try! realm.object(ofType: MonitoredAction.self, forPrimaryKey: ID) {
                    try realm.write {
                        realm.delete(action)
                    }
                }
            }
        } catch {
            print("Error deleting actions: \(error.localizedDescription)")
        }
    }
}

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
