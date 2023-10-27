//
//  DailySummaryView.swift
//  EyeRub
//
//  Created by Tom MERY on 12.07.23.
//

import SwiftUI
import RealmSwift

struct DailySummaryView: View {
    var actions: [Action]
    @Environment(\.realm) private var realm
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    var body: some View {
        VStack {
            List {
                Section("Daily Statistics") {
                    StatisticsView(actions: actions)
                }
                
                Section("Records") {
                    ForEach(actions, id: \._id) { action in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            
                            Text(action.label)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            
                            Text(timeFormatter.string(from: action.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                        }
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
                    }
                    .onDelete(perform: deleteActions)
                }
            }
        }
        .navigationBarTitle(dateFormatter.string(from: actions.first?.timestamp ?? Date()),
                            displayMode: .inline)
    }
    
    func deleteActions(at offsets: IndexSet) {
        for index in offsets {
            if actions.indices.contains(index) {
                let ID = actions[index]._id
                
                if let action = actions[index] as? LabeledAction {
                    if let action = try! realm.object(ofType: LabeledAction.self, forPrimaryKey: ID) {
                        do {
                            try realm.write {
                                realm.delete(action)
                            }
                        } catch {
                            print("Error deleting actions: \(error.localizedDescription)")
                        }
                    }
                }
                else if let action = actions[index] as? MonitoredAction {
                    if let action = try! realm.object(ofType: MonitoredAction.self, forPrimaryKey: ID) {
                        do {
                            try realm.write {
                                realm.delete(action)
                            }
                        } catch {
                            print("Error deleting actions: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
}
