//
//  OrgSignupViewModel.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-14.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Firebase
import Combine

class OrgSignupViewModel: ObservableObject {
    
    @Published var uni_domain: String? = nil
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var is_club = false    
    @Published var waitingForResult = false
    
    let db = Firestore.firestore()
    
    // Allows us to dismiss LoginView when shouldDismissView changes to true
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    
/* INPUT CHECK */
    
    // Basic check before connecting to firebase
    func inputOk() -> Bool{
        return (
            nonEmpty() && validEmail() && validPassword() && validConfirmPassword() && uni_domain != nil
        )
    }
    
    // Used to activate sign up button
    func nonEmpty() -> Bool {
        return (!email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty)
    }
    
    // Check if email is valid
    func validEmail() -> Bool {
        return (email.contains("@") && email.contains("."))
    }
    
    // Check password is over 6 chars long
    func validPassword() -> Bool {
        return password.count > 6
    }
    
    // Make sure passwords match
    func validConfirmPassword() -> Bool {
        return confirmPassword == password
    }
    
    
/* FIREBASE */
// ORDER: create auth user -> create user document in db -> dismiss view -> send verification email
    
    // Create auth user
    func attemptSignup() {
        waitingForResult = true
        
        // Final Check
        if (!inputOk()){
            print("Invalid input.")
            self.shouldDismissView = false
            waitingForResult = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password)
        { (result, error) in
            if (error == nil) {
                self.registerinDB()
                print("New user Created!")
            } else {
                print("Error signing up new user.")
                print(error!)
                self.shouldDismissView = false
                self.waitingForResult = false
            }
        }
    }
    
    // Create an Organization document in Database
    func registerinDB() {
        if let id = Auth.auth().currentUser?.uid {
            
            let newOrg = User(id: id, email: self.email, is_club: self.is_club)
            newOrg.uni_domain = self.uni_domain!
            
            do {
                let _ = try db.collection("users").document(id).setData(from: newOrg)
                print("Organization Document created successfully!")
                self.shouldDismissView = true
                self.waitingForResult = false
                
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if (error == nil){
                        print("Verification Email sent!")
                    } else {
                        print(error!)
                    }
                }
            }
            catch {
                print("Unable to encode task: \(error.localizedDescription)")
                self.shouldDismissView = false
                self.waitingForResult = false
            }
        }
    }
}

