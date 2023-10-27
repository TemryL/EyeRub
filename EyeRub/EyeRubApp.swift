//
//  EyeRub.swift
//  EyeRub
//
//  Created by Tom MERY on 09.12.22.
//

import SwiftUI
import RealmSwift

let appConfig = loadAppConfig()
let realmApp = RealmSwift.App(id: appConfig.appId)


@main
struct EyeRubApp: SwiftUI.App {
    @StateObject var errorHandler = ErrorHandler(app: realmApp)
    @StateObject private var authentificationController = AuthentificationController()
    @State var setNewPassword = false
    
    var body: some Scene {
        WindowGroup {            
            ContentView(app: realmApp)
                .environmentObject(errorHandler)
                .environmentObject(authentificationController)
                .onAppear{
                    // Send empty message to Iphone to make sure WCSession is activated
                    WatchConnectivityManager.shared.send(message: ["":""])
                }
                .alert(Text("Error"), isPresented: .constant(errorHandler.error != nil)) {
                    Button("OK", role: .cancel) { errorHandler.error = nil }
                } message: {
                    Text(errorHandler.error?.localizedDescription ?? "")
                }
//                .onReceive(authentificationController.error){
//                    errorHandler.error = authentificationController.error
//                }
                .alert(Text("Error"), isPresented: .constant(authentificationController.error != nil)) {
                    Button("OK", role: .cancel) { authentificationController.error = nil }
                } message: {
                    Text(authentificationController.error?.localizedDescription ?? "")
                }
                .alert("Reset your password", isPresented: $setNewPassword) {
                    SecureField("New Password", text: $authentificationController.password)
                        .autocorrectionDisabled(true)
                    Button("Reset", action: {
                        Task {
                            await authentificationController.resetPassword()
                            setNewPassword = false
                        }
                    })
                    Button("Cancel", role: .cancel) { }
                }
                .onOpenURL { url in
                    let urlString = url.absoluteString.replacingOccurrences(of: "eyerub://", with: "")
                    let task = urlString.split(separator: "/")[0]

                    switch task {
                    case "email_confirmation":
                        let status = urlString.split(separator: "/")[1]
                        if status == "success" {
                            Task {
                                await authentificationController.login()
                            }
                        }

                    case "reset_password":
                        if let url = URLComponents(string: urlString) {
                            if let token = url.queryItems?.first(where: { $0.name == "token" })?.value,
                               let tokenId = url.queryItems?.first(where: { $0.name == "tokenId" })?.value {
                                authentificationController.token = token
                                authentificationController.tokenId = tokenId
                                setNewPassword = true
                            }
                        }

                    default:
                        print("Unable to parse opened URL")
                    }
                }
        }
    }
}
