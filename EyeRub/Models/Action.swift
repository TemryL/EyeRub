//
//  Action.swift
//  EyeRub
//
//  Created by Tom MERY on 17.10.2023.
//

import Foundation
import RealmSwift

protocol Action {
    var _id: ObjectId { get }
    var timestamp: Date { get }
    var userID: String { get }
    var label: String { get }
}
