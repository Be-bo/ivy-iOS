//
//  LoginViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-12.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Firebase
import Combine

class LoginViewModel: ObservableObject{
    @Published var email = ""
    @Published var password = ""
    @Published var waitingForResult = false
    
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
        waitingForResult = true
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if(error == nil){
                print("Signed in!")
                self.waitingForResult = false
                self.shouldDismissView = true
            }else{
                self.waitingForResult = false
                self.shouldDismissView = false
                print("Error signing in with Auth.")
            }
        }
    }
}
