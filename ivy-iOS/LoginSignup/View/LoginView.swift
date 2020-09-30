//
//  Login.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    // MARK: Variables
    @ObservedObject var thisUserRepo : ThisUserRepo
    //    @ObservedObject var loginVM = LoginViewModel()
    @State var showingStudentSignup = false
    @State var showingOrgSignup = false
    @State var loadInProgress = false
    @State var showEmailResentAlert = false
    @State var displayResendVerifEmail = false
    @State var email = ""
    @State var password = ""
    @State var errorText = ""
    @Environment(\.presentationMode) private var presentationMode
    
    
    
    // MARK: Functions
    func inputOk() -> Bool{ //if basic input checks are ok return true
        if(!email.isEmpty && !password.isEmpty && password.count > 6 && email.contains("@") && email.contains(".")){
            return true
        }else{
            return false
        }
    }
    
    func attemptLogin() { // Sign out first just in case...
        try? Auth.auth().signOut()
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if (error == nil && result != nil /* && result!.user.isEmailVerified*/) {
                self.errorText = ""
                self.displayResendVerifEmail = false
                print("LOGGED IN")
                self.presentationMode.wrappedValue.dismiss()
            }
            else {
//                if (result != nil && !result!.user.isEmailVerified) { // Email not verified yet
//                    self.errorText = "Email not verified yet!"
//                    self.displayResendVerifEmail = true
//                }
//                else { // wrong credentials
                    self.errorText = "Login failed, invalid email or password."
                    self.displayResendVerifEmail = false
                    print(error ?? "")
//                }
                print(self.errorText)
            }
            self.loadInProgress = false
        }
    }
    
//    func resendVerificationEmail(){
//        print("resending")
//        if Auth.auth().currentUser != nil{
//            Auth.auth().currentUser!.sendEmailVerification { (error) in
//                if error != nil{
//                    print("There was an error resending notification email.")
//                    print(error?.localizedDescription)
//                }
//                print("DONE")
//            }
//        }
//    }
    
    
    
    
    // MARK: View
    var body: some View {
        
        VStack(){
            // MARK: Logo
            Logo()
            
            
            // MARK: Input Fields
            TextField("Email", text: $email).textContentType(.emailAddress).autocapitalization(.none)
            Divider().padding(.bottom)
            SecureField("Password", text: $password).textContentType(.password)
            Divider().padding(.bottom)
            
            if (errorText != "") {
                Text(errorText).foregroundColor(AssetManager.ivyNotificationRed).padding(.bottom)
            }
            
            
            
            
            Button(action: {
                self.loadInProgress = true
                self.attemptLogin()
            }){
                Text("Log in")
            }
                .disabled(!inputOk() || loadInProgress) //button is disabled either when input not ok or when we're waiting for a Firebase result
                .buttonStyle(StandardButtonStyle(disabled: !inputOk() || loadInProgress)) //setting button style where background color changes based on if input is ok
            
            
            
            
            
            
            
            // MARK: Resend Verif Email & Signup Buttons
            HStack {
                Spacer()
                
                VStack(alignment: .trailing) {
                    
                    //MARK: commenting out verification email btn
//                    if(self.displayResendVerifEmail){
//                        Text("Resend Verification Email")
//                            .padding(.top)
//                            .foregroundColor(AssetManager.ivyGreen)
//                            .onTapGesture(perform: {
//                                self.showEmailResentAlert.toggle()
//                                self.resendVerificationEmail()
//                            })
//                            .alert(isPresented: self.$showEmailResentAlert) {
//                                Alert(title: Text("Verification Email Sent!"), message: Text("It may take up to 24 hours."), dismissButton: .default(Text("OK")))
//                        }
//
//                    }
                    
                    Button(action: {
                        self.showingStudentSignup.toggle()
                    }){
                        Text("Student Signup").foregroundColor(AssetManager.ivyGreen)
                    }
                    .sheet(isPresented: $showingStudentSignup){
                        StudentSignup()
                    }
                    .padding(.top, 50)
                    
                    
                    Button(action: {
                        self.showingOrgSignup.toggle()
                    }){
                        Text("Organization Signup").foregroundColor(AssetManager.ivyGreen)
                    }.sheet(isPresented: $showingOrgSignup){
                        OrganizationSignup()
                    }
                    .padding(.top)
                }
            }
            
            Spacer()
        }.padding()
            .keyboardAdaptive()
            .onTapGesture { //hide keyboard when background tapped
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        }
        .foregroundColor(Color.black)
    }
}





