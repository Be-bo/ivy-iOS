//
//  StudentSignup.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-13.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

// Main View
struct StudentSignup: View {
    @ObservedObject var studentSignupVM = StudentSignupViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @State var errorText: SignupError? = nil
    @State var showAlert = false

    var body: some View {
        ZStack { // for alert dialog
            
            ZStack(alignment: .topLeading) { // for backbutton
                
                VStack(){
                    
                    Logo()
                    
                    EmailField(email: $studentSignupVM.email)
                    PasswordField(password: $studentSignupVM.password)
                    PasswordField(hint: "Confirm Password",
                                  password: $studentSignupVM.confirmPassword)
                        
                    DropDownMenu(
                        selected: $studentSignupVM.degree,
                        list: StaticDegreesList.degree_array,
                        hint: "Degree",
                        hintColor: Color.gray,
                        background: Color.white,
                        expandedHeight: 200
                    )
                    
                    // Error text
                    Text(errorText?.rawValue ?? "")
                        .foregroundColor(AssetManager.ivyNotificationRed)
                        .padding(.bottom)
                    
                    // Display loading instead of button when waiting for results from Firebase
                    HStack {
                        if (studentSignupVM.waitingForResult) {
                            LoadingSpinner()
                        }
                        else {
                            Button(action: {
                                self.studentSignupVM.attemptSignup()
                                self.errorText = nil
                            }){
                                Text("Sign Up")
                            }
                                .disabled(!studentSignupVM.nonEmpty() || studentSignupVM.waitingForResult)
                                .buttonStyle(StandardButtonStyle(disabled: !studentSignupVM.nonEmpty()))
                        }
                    } // VM will send a signal whenever shouldDismiss changes value
                    .onReceive(studentSignupVM.viewDismissalModePublisher) { shouldDismiss in
                        if shouldDismiss {
                            self.showAlert = true
                        } else { // There was an error -> identify and give feedback to user
                            if (!self.studentSignupVM.validDomain()) {
                                self.errorText = SignupError.invalidDomain
                            }
                            else if (!self.studentSignupVM.validEmail()) {
                                self.errorText = .invalidEmail
                            }
                            else if (self.studentSignupVM.degree == nil) {
                                self.errorText = .noDegreeSelected
                            }
                            else if (!self.studentSignupVM.validPassword()) {
                                self.errorText = .shortPassword
                            }
                            else if (!self.studentSignupVM.validConfirmPassword()) {
                                self.errorText = .invalidPasswordMatch
                            }
                            else {
                                self.errorText = .emailExists
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30.0)
                .background(Gradient())
            
                // Back Button
                HStack {
                    BackButton {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                }
                .padding(.top)
                .padding(.leading)
            }
            
            // Show an alert when successfully signed up
            if showAlert {
                PopUpAlert(
                    message: "Welcome to Ivy! We've sent you a confirmation email.",
                    action: {
                        self.showAlert = false
                        self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

// Preview
struct StudentSignup_Previews: PreviewProvider {
    static var previews: some View {
        StudentSignup()
    }
}
