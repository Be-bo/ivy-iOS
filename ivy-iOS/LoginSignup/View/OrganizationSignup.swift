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

    var body: some View {
        ZStack(alignment: .topLeading) {
            
            VStack(){

                Logo()
                
                EmailField(emailContainer: $orgSignupVM.email)
                PasswordField(passwordContainer: $orgSignupVM.password)
                PasswordField(hint: "Confirm Password",
                              passwordContainer: $orgSignupVM.confirmPassword)
                                
                Toggle(isOn: $orgSignupVM.is_club) {
                    Text("We are a club")
                }
                .padding(.bottom, 30.0)
                
                Button(action: {
                    self.orgSignupVM.attemptSignup()
                }){
                    Text("Organization Sign Up")
                }
                // Button disabled either when input not ok or when waiting for a Firebase result
                .disabled(!orgSignupVM.inputOk() || orgSignupVM.waitingForResult)
                // setting button style where background color changes based on if input is ok
                .buttonStyle(StandardButtonStyle(disabled: !orgSignupVM.inputOk()))
                // when shouldDismiss changes to true, dismiss this sheet
                .onReceive(orgSignupVM.viewDismissalModePublisher) { shouldDismiss in
                    if shouldDismiss {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        //MARK: TODO
                        //self.errorText = "Your email or password is invalid."
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
    }
}

// Preview
struct OrganizationSignup_Previews: PreviewProvider {
    static var previews: some View {
        OrganizationSignup()
    }
}
