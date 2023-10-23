//
//  AuthentificationController.swift
//  EyeRub
//
//  Created by Tom MERY on 08.09.23.
//

import Foundation
import RealmSwift

class AuthentificationController: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    var token = ""
    var tokenId = ""
    @Published var error: Swift.Error?
    @Published var showAlert = false
    @Published var alertMessage = ""
    private var googleAuthController = GoogleAuthController()
    
    /// Logs in with an existing user.
    func login() async {
        do {
            let user = try await realmApp.login(credentials: Credentials.emailPassword(email: email, password: password))
            print("Successfully logged in user: \(user)")
        } catch {
            print("Failed to log in user: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    /// Registers a new user with the email/password authentication provider.
    func signUp() async {
        do {
            try await realmApp.emailPasswordAuth.registerUser(email: email, password: password)
            print("Successfully registered user")
            self.alertMessage = "Check your mailbox, an email has been sent to verify your adress."
            self.showAlert = true
        } catch {
            print("Failed to register user: \(error.localizedDescription)")
            self.error = error
        }
    }
    
    /// Send email for password reset
    func sendResetPasswordEmail() {
        realmApp.emailPasswordAuth.sendResetPasswordEmail(email) { error in
            if let error = error {
                self.error = error
            }
            else {
                self.alertMessage = "Check your mailbox, an email has been sent to reset your password."
                self.showAlert = true
            }
        }
        self.showAlert = false
    }
    
    /// Reset password
    func resetPassword() async {
        do {
            try await realmApp.emailPasswordAuth.resetPassword(to: password, token: token, tokenId: tokenId)
            print("Successfully reset password")
            await login()
        } catch {
            print("Failed to reset password: \(error.localizedDescription)")
            self.error = error
        }
    }
        
    func performGoogleSignIn() {
        googleAuthController.signIn() {
            if self.googleAuthController.showAlert {
                self.error = self.googleAuthController.error
                self.googleAuthController.showAlert = false
            }
            else {
                let idToken = self.googleAuthController.sharedInstance.currentUser?.idToken?.tokenString
                let credentials = Credentials.googleId(token: idToken!)
                
                realmApp.login(credentials: credentials) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .failure(let error):
                            print("Failed to log in to MongoDB Realm: \(error)")
                            self.error = error
                        case .success(let user):
                            print("Successfully logged in to MongoDB Realm using Google OAuth.")
                            // Now logged in, do something with user
                            // Remember to dispatch to main if you are doing anything on the UI thread
                        }
                    }
                }
            }
        }
    }

    func performAppleSignIn(idToken: String) {
        let credentials = Credentials.apple(idToken: idToken)
        realmApp.login(credentials: credentials) { (result) in
            switch result {
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
                self.error = error
            case .success(let user):
                print("Successfully logged in to MongoDB Realm using Apple OAuth.")
                // Now logged in, do something with user
                // Remember to dispatch to main if you are doing anything on the UI thread
            }
        }
    }
}
