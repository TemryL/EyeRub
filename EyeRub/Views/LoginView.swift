import SwiftUI
import RealmSwift
import AuthenticationServices

/// Log in or register users using email/password authentication
struct LoginView: View {
    @State var confirmedPassword = ""
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoggingIn = false
    @State private var isCreatingAccount = false
    @State private var isResetingPassword = false
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var authentificationController: AuthentificationController

    var body: some View {
        VStack {
            if isLoggingIn {
                ProgressView()
            }
            
            VStack {
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("EyeRub")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                Group {
                    TextField("Email", text: $authentificationController.email)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $authentificationController.password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    if !isCreatingAccount {
                        Button(action: {
                            authentificationController.sendResetPasswordEmail()
                        }){
                            HStack {
                                Spacer()
                                
                                Text("Reset Password")
                                    .bold()
                                    .foregroundColor(Color("lightBlue"))
                            }
                            .padding(.horizontal)
                            .padding(.bottom)

                        }
                        .disabled(isLoggingIn)
                    }
                    
                    if isCreatingAccount {
                        SecureField("Confirm Password", text: $confirmedPassword)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // Button pressed, so create account and then log in
                            isLoggingIn = true
                            Task {
                                await authentificationController.signUp()
                                isLoggingIn = false
                            }
                            isCreatingAccount = false
                        }){
                            if authentificationController.password == confirmedPassword {
                                SignInButton(provider: .register)
                            }
                            else {
                                Text("Please enter the same passwords")
                                    .foregroundColor(.gray)
                            }
                        }
                        .disabled(isLoggingIn)
                    }
                    else {
                        Button(action: {
                            isLoggingIn = true
                            Task {
                                await authentificationController.login()
                                isLoggingIn = false
                            }
                        }){
                            SignInButton(provider: .email)
                        }
                        .disabled(isLoggingIn)
                    }
                }
                
                Group {
                    HStack {
                        VStack {
                            Divider()
                        }
                        Text("Or")
                            .foregroundColor(.gray)
                        
                        VStack {
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }

                Group {
                    VStack{
                        Button(action: authentificationController.performGoogleSignIn){
                            SignInButton(provider: .google)
                        }
                        .disabled(isLoggingIn)
                        
                        SignInWithAppleButton(
                            onRequest: { request in
                                // Configure the requested scopes if needed
                                request.requestedScopes = [.email, .fullName]
                            },
                            onCompletion: { result in
                                switch result {
                                    case .success(let authResults):
                                        // Handle successful sign-in here
                                        print("Authorization successful")
                                        guard let credentials = authResults.credential as? ASAuthorizationAppleIDCredential, let identityToken = credentials.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) else { return }
                                    
                                    authentificationController.performAppleSignIn(idToken: identityTokenString)
                                    
                                    case .failure(let error):
                                        // Handle sign-in error here
                                        print("Authorization failed: \(error.localizedDescription)")
                                        errorHandler.error = error
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .disabled(isLoggingIn)
                    }
                }
                
                if !isCreatingAccount {
                    Group {
                        
                        Divider().padding()
                        
                        Text("Don't have an account?").bold()
                        
                        Button(action: {
                            isCreatingAccount = true
                        }){
                            SignInButton(provider: .noAccount)
                        }
                        .disabled(isLoggingIn)
                    }
                }
                else {
                    Group {
                        
                        Divider().padding()
                        
                        Text("Already have an account?").bold()
                        
                        Button(action: {
                            isCreatingAccount = false
                        }){
                            SignInButton(provider: .existingAccount)
                        }
                        .disabled(isLoggingIn)
                    }
                }
            }
        }
        .alert(isPresented: $authentificationController.showAlert) {
            Alert(title: Text("Alert"), message: Text(authentificationController.alertMessage),
                  dismissButton: Alert.Button.default(
                      Text("Ok"), action: {
                          authentificationController.showAlert = false
                          dismiss()
                      }
                  )
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthentificationController())
    }
}
