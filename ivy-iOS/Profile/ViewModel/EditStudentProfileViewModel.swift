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
    
    @Published var inputImage: UIImage? = nil
    @Published var image: Image? = nil
    @Published var name: String
    @Published var degree: String?
    @Published var is_private: Bool
    
    @Published var selectedBD = Date()
    @Published var waitingForResult = false

    
    @ObservedObject var thisUserRepo : ThisUserRepo
    
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
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
        self.name = thisUserRepo.user.name
        self.degree = thisUserRepo.user.degree
        self.selectedBD = Utils.convertMillisToDate(millis: Double(thisUserRepo.user.birth_millis))
        self.is_private = thisUserRepo.user.is_private
    }
        
    // Basic check before connecting to firebase
    func inputOk() -> Bool{
        return (
            !name.isEmpty && degree != nil
        )
    }
  
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }

/* FIREBASE */
    
    // TODO: quick and dirty
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
        
        let updatedStudent = thisUserRepo.user
        updatedStudent.name = self.name
        if let degree = self.degree {
            updatedStudent.degree = degree
        }
        updatedStudent.birth_millis = Int(Utils.convertDateToMillis(date: self.selectedBD))
        updatedStudent.is_private = self.is_private
        
        do {
            let _ = try db.collection("users").document(updatedStudent.id ?? "nil").setData(from: updatedStudent)
            
            // Upload image
            if (self.image != nil) {
                self.storageRef.child(updatedStudent.profileImagePath()).putData((self.inputImage!.jpegData(compressionQuality: 0.7))!, metadata: nil){ (error, metadata) in
                    if(error != nil){
                        print("Could not upload full image: \(error!)")
                    }
                    self.storageRef.child(updatedStudent.previewImagePath()).putData((self.inputImage?.jpegData(compressionQuality: 0.1))!, metadata: nil){ (error1, metadata1) in
                        if(error1 != nil){
                            print("Could not upload preview image: \(error1!)")
                        }
                        self.shouldDismissView = true
                    }
                }
            }
            else {
                print("Student updated!")
                self.shouldDismissView = true
            }
        }
        catch {
            print("Unable to encode task: \(error.localizedDescription)")
            self.shouldDismissView = false
        }
        self.waitingForResult = false
    }

}
