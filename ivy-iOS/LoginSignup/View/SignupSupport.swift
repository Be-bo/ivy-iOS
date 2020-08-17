//
//  SignupSupport.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-13.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

// Gradient
struct Gradient: View {
    var body: some View {
        LinearGradient(
            gradient: .init(colors: [AssetManager.ivyGreen, Color.white, Color.white, Color.white]),
            startPoint: .bottom,
            endPoint: .top)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture { //hide keyboard when background tapped
            UIApplication
                .shared
                .sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to:nil, from:nil, for:nil
                )
        }
    }
}

// Ivy Logo
struct Logo: View {
    var body: some View {
        Image("LogoGreen")
        .resizable()
        .frame(width: 200, height: 200, alignment: .center)
    }
}

// Custom BackButton
struct BackButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
    }
}

// Email Field
struct EmailField: View {
    var hint = "Email"
    var emailContainer: Binding<String>
    
    var body: some View {
        Group {
            TextField(hint, text: emailContainer)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            Divider().padding(.bottom)
        }
    }
}

// Password Field
struct PasswordField: View {
    var hint = "Password"
    var passwordContainer: Binding<String>
    
    var body: some View {
        Group {
            SecureField(hint, text: passwordContainer)
                .textContentType(.password)
            Divider().padding(.bottom)
        }
    }
}


