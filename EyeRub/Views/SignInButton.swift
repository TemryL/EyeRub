//
//  SignInButton.swift
//  EyeRub
//
//  Created by Tom MERY on 30.08.23.
//

import SwiftUI

enum Provider {
    case email
    case google
    case apple
    case register
    case noAccount
    case existingAccount
}

struct SignInButton: View {
    var provider: Provider
    @Environment(\.colorScheme) var colorScheme
    let textFont: Font = .subheadline
    
    var backgroundColor: Color {
        switch provider {
        case .email:
            return .brown
        case .google:
            return .white
        case .apple:
            return colorScheme == .dark ? .white : .black
        case .register:
            return .brown
        case .noAccount:
            return .gray
        case .existingAccount:
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            switch provider {
            case .email:
                Text("Sign in")
                    .font(textFont)
                    .foregroundColor(.white)
                    .bold()
                
            case .google:
                ZStack {
                     RoundedRectangle(cornerRadius: 8, style: .continuous)
                         .fill(backgroundColor)
                         .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2) // Add shadow only for Google button
                     
                    HStack(spacing: 4){
                         Image("GoogleLogo")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 12, height: 12)
                         
                         Text("Sign in with Google")
                             .font(textFont)
                             .foregroundColor(.gray)
                             .bold()
                     }
                 }
            case .apple:
                Image(systemName: "applelogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                
                Text("Sign in with Apple")
                    .font(textFont)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .bold()
                
            case .register:
                Text("Register")
                    .font(textFont)
                    .foregroundColor(.white)
                    .bold()
            
            case .noAccount:
                Text("Create Account")
                    .font(textFont)
                    .foregroundColor(.white)
                    .bold()
                
            case .existingAccount:
                Text("Use Existing Account")
                    .font(textFont)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(backgroundColor)
        )
        .padding(.horizontal)
    }
}

struct SignInButton_Previews: PreviewProvider {
    static var previews: some View {
        SignInButton(provider: .apple)
    }
}
