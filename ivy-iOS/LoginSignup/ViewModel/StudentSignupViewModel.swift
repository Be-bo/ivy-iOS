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
    
    // Check basic input checks are ok return true
    func inputOk() -> Bool{
        //MARK: TODO a better input check system and feedback
        
        return (
            !email.isEmpty && !password.isEmpty && email.contains("@") &&
            email.contains(".") && password.count > 6 &&  confirmPassword == password &&
            degree != nil
        )
    }
    
    // Create auth user
    func attemptSignup() {
        waitingForResult = true
        Auth.auth().createUser(withEmail: email, password: password)
        { (result, error) in
            if (error == nil) {
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
            
            let newStudent = Student(id: id, email: self.email, degree: self.degree!)
            
            do {
                let _ = try db.collection("users").addDocument(from: newStudent)
                
                print("Student Document created successfully!")
                self.shouldDismissView = true
            }
            catch {
                print("Unable to encode task: \(error.localizedDescription)")
                self.shouldDismissView = false
            }
            self.waitingForResult = false
        }
    }
}


