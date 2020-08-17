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

    var body: some View {
        ZStack(alignment: .topLeading) {
        
            VStack(){
                
                Logo()
                
                EmailField(emailContainer: $studentSignupVM.email)
                PasswordField(passwordContainer: $studentSignupVM.password)
                PasswordField(hint: "Confirm Password",
                              passwordContainer: $studentSignupVM.confirmPassword)
                    
                DropDownMenu(
                    selected: $studentSignupVM.degree,
                    list: StaticDegreesList.degree_array,
                    hint: "Degree",
                    hintColor: Color.gray,
                    background: Color.white,
                    expandedHeight: 200
                )
                
                Button(action: {
                    self.studentSignupVM.attemptSignup()
                }){
                    Text("Sign Up")
                }
                // Button disabled either when input not ok or when waiting for a Firebase result
                .disabled(!studentSignupVM.inputOk() || studentSignupVM.waitingForResult)
                // setting button style where background color changes based on if input is ok
                .buttonStyle(StandardButtonStyle(disabled: !studentSignupVM.inputOk()))
                // when shouldDismiss changes to true, dismiss this sheet
                .onReceive(studentSignupVM.viewDismissalModePublisher) { shouldDismiss in
                    if shouldDismiss {
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        // MARK: TODO
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
struct StudentSignup_Previews: PreviewProvider {
    static var previews: some View {
        StudentSignup()
    }
}
