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
    @ObservedObject var loginVM = LoginViewModel()
    @State var showingStudentSignup = false
    @State var showingOrgSignup = false
    @State var loadInProgress = false
    @State var showEmailResentAlert = false
    @Environment(\.presentationMode) private var presentationMode
    
    
    
    // MARK: Body
    var body: some View {
        
        ZStack(){
            
            // MARK: Background and Logo
            ZStack(alignment: .top){
                LinearGradient(gradient: .init(colors: [AssetManager.ivyGreen, Color.white, Color.white, Color.white]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
                AssetManager.logoWhite
                    .resizable().frame(width: 200, height: 200, alignment: .top)
            }.onTapGesture { //hide keyboard when background tapped
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            }
            
            
            
            VStack(alignment: .leading){
                
                // MARK: Input Fields
                TextField("Email", text: $loginVM.email).textContentType(.emailAddress).autocapitalization(.none)
                Divider().padding(.bottom)
                SecureField("Password", text: $loginVM.password).textContentType(.password)
                Divider().padding(.bottom)
                
                if (!loginVM.waitingForResult) {
                    Text(loginVM.errorText).foregroundColor(AssetManager.ivyNotificationRed).padding(.bottom)
                }
                
                
                
                
                Button(action: {
                    self.loadInProgress = true
                    self.loginVM.attemptLogin()
                }){
                    Text("Log in")
                }
                    .disabled(!loginVM.inputOk() || loginVM.waitingForResult || loadInProgress) //button is disabled either when input not ok or when we're waiting for a Firebase result
                    .buttonStyle(StandardButtonStyle(disabled: !loginVM.inputOk() || loginVM.waitingForResult || loadInProgress)) //setting button style where background color changes based on if input is ok
                    .onReceive(loginVM.viewDismissalModePublisher) { shouldDismiss in //when shouldDismiss changes to true, dismiss this sheet
                        if shouldDismiss {
                            self.presentationMode.wrappedValue.dismiss()
                            self.thisUserRepo.login()
                        } else {
                            self.loadInProgress = false
                        }
                }
                
                
                
                
                
                
                // MARK: Resend Verif Email & Signup Buttons
                HStack {
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        
                        if(self.loginVM.displayResendVerifEmail){
                            Text("Resend Verification Email")
                                .foregroundColor(AssetManager.ivyGreen)
                                .onTapGesture(perform: {
                                    self.showEmailResentAlert.toggle()
                                    self.loginVM.resendVerificationEmail()
                                })
                                .alert(isPresented: self.$showEmailResentAlert) {
                                    Alert(title: Text("Verification Email Sent"), message: Text(""), dismissButton: .default(Text("OK")))
                                }
                        
                        }
                        
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

            }
            .padding()
        }
    }
}










// MARK: Preview

//struct Login_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
