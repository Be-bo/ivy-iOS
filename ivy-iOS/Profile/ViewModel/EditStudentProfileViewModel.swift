//
//  EditStudentProfileViewModel.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-24.
//  Copyright © 2020 ivy. All rights reserved.
//

import FirebaseStorage
import Foundation
import SwiftUI
import Firebase
import Combine

class EditStudentProfileViewModel: ObservableObject {
    
    @State var inputImage: UIImage? = nil
    @Published var name: String
    @Published var degree: String?
    @Published var birth_millis: Int
    @Published var is_private: Bool
    
    @Published var selectedBD = Date()
    @Published var waitingForResult = false

    
    @ObservedObject var thisUserRepo : ThisUserRepo
    
    let db = Firestore.firestore()
    
    // Allows us to dismiss LoginView when shouldDismissView changes to true
    var viewDismissalModePublisher = PassthroughSubject<Bool, Never>()
    private var shouldDismissView = false {
        didSet {
            viewDismissalModePublisher.send(shouldDismissView)
        }
    }
    
    // Initialize all fields to their current values
    init(thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        self.name = thisUserRepo.thisUser.name
        self.degree = thisUserRepo.thisUser.degree
        self.birth_millis = thisUserRepo.thisUser.birth_millis
        self.is_private = thisUserRepo.thisUser.is_private
    }
        
    // Basic check before connecting to firebase
    func inputOk() -> Bool{
        return (
            !name.isEmpty && degree != nil
        )
    }
    

/* FIREBASE */
    
    // Update User document in Firebase
    func updateInDB() {
        waitingForResult = true
        
        // Final Check
        if (!inputOk()) {
            print("Invalid Input. Cannot update student.")
            shouldDismissView = false
            waitingForResult = false
            return
        }
        
        let updatedStudent = thisUserRepo.thisUser
        
        
        do {
            let _ = try db.collection("users").document(id).setData(from: newStudent)
            
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
