//
//  OrganizationSignup.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-11.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

// Main View
struct OrganizationSignup: View {
    
    @ObservedObject var orgSignupVM = OrgSignupViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @State var errorText: SignupError? = nil
    @State var showAlert = false
    
    var body: some View {
        ZStack { // For alert popup
            
            ZStack(alignment: .topLeading) { // for backbutton
                
                VStack(){

                    Logo()

                    DropDownMenu(
                        selected: $orgSignupVM.uni_domain,
                        list: StaticDomainList.available_domain_list,
                        hint: "University",
                        background: Color.white,
                        expandedHeight: 200
                    )

                    EmailField(email: $orgSignupVM.email)
                    PasswordField(password: $orgSignupVM.password)
                    PasswordField(hint: "Confirm Password",
                                  password: $orgSignupVM.confirmPassword)

                    Toggle(isOn: $orgSignupVM.is_club) {
                        Text("We are a club")
                    }
                    .padding(.bottom, 30.0)

                    // Error Text
                    Text(errorText?.rawValue ?? "")
                        .foregroundColor(AssetManager.ivyNotificationRed)
                        .padding(.bottom)

                    // Display loading instead of button when waiting for results from Firebase
                    HStack {
                        if (orgSignupVM.waitingForResult) {
                            LoadingSpinner()
                        }
                        else {
                            Button(action: {
                                self.orgSignupVM.attemptSignup()
                                self.errorText = nil
                            }){
                                Text("Organization Sign Up")
                            }
                            .disabled(!orgSignupVM.nonEmpty() || orgSignupVM.waitingForResult)
                            .buttonStyle(StandardButtonStyle(disabled: !orgSignupVM.nonEmpty()))
                        }
                    } // VM will send a signal whenever shouldDismiss changes value
                        .onReceive(orgSignupVM.viewDismissalModePublisher) { shouldDismiss in
                            if shouldDismiss {
                                self.showAlert = true
                            } else { // There was an error -> identify and give feedback to user
                                if (self.orgSignupVM.uni_domain == nil) {
                                    self.errorText = .noUniSelected
                                }
                                else if (!self.orgSignupVM.validEmail()) {
                                    self.errorText = .invalidEmail
                                }
                                else if (!self.orgSignupVM.validPassword()) {
                                    self.errorText = .shortPassword
                                }
                                else if (!self.orgSignupVM.validConfirmPassword()) {
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
struct OrganizationSignup_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationSignup()
    }
}
