//
//  StudentSignupViewModel.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-17.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Firebase
import Combine

class StudentSignupViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var degree: String? = nil
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
            nonEmpty() && validEmail() && validPassword() &&
                validConfirmPassword() && degree != nil
        )
    }
    
    // Used to activate sign up button
    func nonEmpty() -> Bool {
        return (!email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty)
    }
    
    // Check if email is valid
    func validEmail() -> Bool {
        if (email.contains("@") && email.contains(".")) {
            return validDomain()
        }
        return false
    }
    
    // Check if email has a valid uni domain
    func validDomain() -> Bool {
        let email_array = email.split(separator: "@")
        if email_array.count == 2 {
            for domain in StaticDomainList.domain_list {
                if (email_array[1] == domain) {
                    return true
                }
            }
        }
        return false
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
                self.shouldDismissView = true //TODO this might not be a good fix
                Auth.auth().currentUser?.sendEmailVerification { (error) in
                    if (error == nil){
                        self.registerinDB()
                    } else {
                        print(error!)
                    }
                }
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
            
            let newStudent = User(id: id, email: email, degree: self.degree!)
            
            do {
                let _ = try db.collection("users").document(id).setData(from: newStudent)
                
                print("Student Document created successfully!")
                self.waitingForResult = false
            }
            catch {
                print("Unable to encode task: \(error.localizedDescription)")
                self.waitingForResult = false
            }
        }
    }
}


