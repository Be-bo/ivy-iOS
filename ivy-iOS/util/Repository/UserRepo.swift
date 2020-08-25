//
//  UserRepo.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-25.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


class UserRepo: ObservableObject {
    
    @Published var user : User
    @Published var userDocLoaded = false
    
    let db = Firestore.firestore()
    
    
    init() { // Used only by children!!!
        self.user = User()
    }
    
    convenience init(userid: String) {
        self.init()
        self.user.id = userid
        loadUserProfile()
    }
    
    func loadUserProfile(){
        if let id = user.id {
            loadProfile(userid: id)
        }
    }
    
    func updateUserProfile(updatedUser: User) {
        if let id = self.user.id {
            updateProfile(userid: id, updatedUser: updatedUser)
        }
    }
    

/* FIREBASE functions used by children */
    
    // TODO: change to snapshot listener later
    func loadProfile(userid: String) {
        db.collection("users").document(userid).getDocument { (docSnap, err) in
            if err != nil{
                print("Error getting user profile.")
            }
            if let doc = docSnap{
                print("GOT THIS USER")
                self.user.docToObject(doc: doc)
                self.userDocLoaded = true
            }
        }
    }
    
    func updateProfile(userid: String, updatedUser: User) {
        do {
            let _ = try db.collection("users").document(userid).setData(from: updatedUser)
            loadUserProfile()
        }
        catch {
            print("Unable to encode task: \(error.localizedDescription)")
        }
    }
}

