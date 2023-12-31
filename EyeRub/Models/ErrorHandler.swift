//
//  ErrorHandler.swift
//  EyeRub
//
//  Created by Tom MERY on 16.09.23.
//

import Foundation
import RealmSwift

struct ErrorMessage: Identifiable {
    let id = UUID()
    let errorText: String
}

final class ErrorHandler: ObservableObject {
    @Published var error: Swift.Error?

    init(app: RealmSwift.App) {
        // Sync Manager listens for sync errors.
        app.syncManager.errorHandler = { syncError, syncSession in
            self.error = syncError
        }
    }
}

