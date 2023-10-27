//
//  MonitoredAction.swift
//  EyeRub
//
//  Created by Tom MERY on 14.10.23.
//

import Foundation
import RealmSwift

class MonitoredAction: Object, ObjectKeyIdentifiable, Action {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var timestamp = Date()
    @Persisted var userID: String
    @Persisted var wristLocation: String
    @Persisted var crownOrientation: String
    @Persisted var label: String

    convenience init(userID: String, wristLocation: String, crownOrientation: String, label: String) {
        self.init()
        self.userID = userID
        self.wristLocation = wristLocation
        self.crownOrientation = crownOrientation
        self.label = label
    }
}
