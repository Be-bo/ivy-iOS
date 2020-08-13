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
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isClub = true
    
    var frameworks = ["UIKit", "Core Data", "Cloud Kit", "SwiftUI"]
    @State private var selectedFrameworkIndex = 0

    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(spacing: 15){
                        
                        Logo()
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                        
                      
                        Picker(selection: $selectedFrameworkIndex, label: Text("Favorite Frameword")) {
                            ForEach(0 ..< frameworks.count) {
                                Text(self.frameworks[$0])
                            }
                        }
                        //.padding(.bottom, 30.0)
                        
                        Button(action: {
                            //self.loginVM.attemptLogin()
                        }){
                            Text("Sign Up")
                        }
                        //.disabled(!loginVM.inputOk() || loginVM.waitingForResult) //button is disabled either when input not ok or when we're waiting for a Firebase result
                        //.buttonStyle(StandardButtonStyle(disabled: !loginVM.inputOk())) //setting button style where background color changes based on if input is ok
                        //.onReceive(loginVM.viewDismissalModePublisher) { shouldDismiss in //when shouldDismiss changes to true, dismiss this sheet
                          //  if shouldDismiss {
                            //    self.presentationMode.wrappedValue.dismiss()
                            //} else {
                              //  self.errorText = "Your email or password is invalid."
                            //}
                        //}
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30.0)
                }
            }
            .background(Gradient())
        
            
        }
        .navigationBarTitle("Degrees")
    }
}

// Preview
struct StudentSignup_Previews: PreviewProvider {
    static var previews: some View {
        StudentSignup()
    }
}




