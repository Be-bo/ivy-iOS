//
//  LoginViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-12.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import Foundation
import Firebase
import Combine

class LoginViewModel: ObservableObject{
    
    @Published var email = ""
    @Published var password = ""
    @Published var waitingForResult = false
    @Published var errorText = ""
    @Published var displayResendVerifEmail = false
    
    
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>() //allows us to dismiss LoginView when shouldDismissView changes to true
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    func inputOk() -> Bool{ //if basic input checks are ok return true
        if(!email.isEmpty && !password.isEmpty && password.count > 6 && email.contains("@") && email.contains(".")){
            return true
        }else{
            return false
        }
    }
    
    func attemptLogin() { //try to log in (async action Firebase)
        try? Auth.auth().signOut() //to make sure stuff gets refreshed in the main (if email not verified, it logs you in, but doesn't let you in, when the user tries again with a verified email the auth listener needs to refresh)
        waitingForResult = true
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if (error == nil && result != nil && result!.user.isEmailVerified) {
                self.errorText = ""
                print("Signed in!")
                self.shouldDismissView = true
            }
            else {
                if (result != nil && !result!.user.isEmailVerified) { // Email not verified yet
                    self.errorText = "Email not verified yet!"
                    self.displayResendVerifEmail = true
                }
                else { // wrong credentials
                    self.errorText = "Login failed, invalid email or password."
                    print(error ?? "")
                }
                print(self.errorText)
                self.shouldDismissView = false
            }
            self.waitingForResult = false
        }
    }
    
    func resendVerificationEmail(){
        if Auth.auth().currentUser != nil{
            Auth.auth().currentUser!.sendEmailVerification(completion: nil)
        }
    }
}
