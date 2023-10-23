//
//  DeleteAccountButton.swift
//  EyeRub
//
//  Created by Tom MERY on 16.09.23.
//

import SwiftUI
import RealmSwift

struct DeleteAccountButton: View {
    @Environment(\.realm) private var realm
    @State var isDeletingAccount = false
    @State var error: Error?
    @State var errorMessage: ErrorMessage? = nil
    @State var showAlert = false
    var onDeleteAccount: () -> Void
    
    var body: some View {
        Button("Delete Account") {
            showAlert = true
        }
        .disabled(realmApp.currentUser == nil || isDeletingAccount)
        .alert(item: $errorMessage) { errorMessage in
            Alert(
                title: Text("Failed to delete user"),
                message: Text(errorMessage.errorText),
                dismissButton: .cancel()
            )
        }
        // Display the alert when showDeleteAccountAlert is true
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This will permanently erase your account and all the data associated."),
                primaryButton: .cancel() {
                    // User chose to cancel the account deletion
                    showAlert = false
                },
                secondaryButton: .destructive(Text("Confirm")) {
                    // Perform the action deletion and account deletion
                    isDeletingAccount = true
                    onDeleteAccount() // Call the provided closure to delete actions
                    
                    guard let user = realmApp.currentUser else {
                        return
                    }
                    Task {
                        await deleteUser(user: user)
                    }
                    
                    isDeletingAccount = false
                }
            )
        }
        .foregroundColor(.red)
        .bold()
    }
    
    func deleteUser(user: User) async {
        do {
            // If previously signed in with Google, sign out first from Google
            let providerType = user.identities.map{ identity in identity.providerType}[0]
            if providerType == "oauth2-google" {
                GoogleAuthController().sharedInstance.signOut()
            }
            try await user.delete()
            print("Successfully deleted user")
        } catch {
            print("Failed to delete user: \(error.localizedDescription)")
            self.errorMessage = ErrorMessage(errorText: error.localizedDescription)
        }
    }
    
}
