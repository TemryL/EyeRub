//
//  GoogleAuthController.swift
//  EyeRub
//
//  Created by Tom MERY on 22.02.23.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift


class GoogleAuthController: ObservableObject {
    let sharedInstance = GIDSignIn.sharedInstance
    @Published var showAlert = false
    var error: Error?
    
    func signIn(completion: @escaping () -> Void) {
        guard let presentingVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}
        
        // Sign in with previous credentials if any
        if sharedInstance.hasPreviousSignIn() {
            sharedInstance.restorePreviousSignIn() { signInResult, error in
                guard let result = signInResult else {
                    self.error = error
                    self.showAlert = true
                    return
                }
                completion()
            }
        }
        else {
            sharedInstance.signIn(withPresenting: presentingVC, hint: nil, additionalScopes: nil) { signInResult, error in
                guard let result = signInResult else {
                    self.error = error
                    self.showAlert = true
                    return
                }
                completion()
            }
        }
    }
}
