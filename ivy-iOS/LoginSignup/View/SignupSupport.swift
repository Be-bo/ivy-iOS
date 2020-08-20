//
//  SignupSupport.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-13.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI


// Error messages
enum SignupError: String {
    case invalidEmail = "Please enter a valid email."
    case shortPassword = "Your password must be over six characteres long."
    case invalidPasswordMatch = "Passwords do not match."
    case noUniSelected = "Please choose a university."
    case noDegreeSelected = "Please select your degree."
    case invalidDomain = "Please choose a valid University Domain."
    case emailExists = "Registration Failed! This email is already registered."
    case other = "A Sign Up error occured. Please try again later."
}


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
    var color = Color.green
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
        .foregroundColor(color)
    }
}

// Email Field
struct EmailField: View {
    var hint = "Email"
    @Binding var email: String
    
    var body: some View {
        Group {
            TextField(hint, text: $email)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            Divider()
                .background(email != "" ? Color.green : nil)
                .padding(.bottom)
        }
    }
}

// Password Field
struct PasswordField: View {
    var hint = "Password"
    @Binding var password: String
    
    @State private var visible = false
    
    var body: some View {
        VStack {
            
            HStack {
            
                if (visible) {
                    TextField(hint, text: $password)
                        .textContentType(.password)
                }
                else {
                    SecureField(hint, text: $password)
                        .textContentType(.password)
                }
                
                Button(action: {
                    self.visible.toggle()
                }) {
                    Image(systemName: self.visible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color.gray.opacity(0.5))
                }
            }
            
            Divider()
                .background(password != "" ? Color.green : nil)
                .padding(.bottom)
        }
    }
}

// Successful Sign up Alert dialog
func SignupSuccessAlert() -> Alert {
    return
        Alert(
            title: Text("Welcome to Ivy!"),
            message: Text ("We've sent you a confirmation email."),
            dismissButton: .default(Text("Okay"))
        )
}

// Error Image [unused]
struct ErrorImage: View {
    var body: some View {
        Image(systemName: "exclamation.circle.fill")
            .resizable()
            .frame(width: 10, height: 10)
            .foregroundColor(.red)
    }
}
