//
//  ThisUserRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ThisUserRepo: ObservableObject{
    let db = Firestore.firestore()
    @Published var thisUser = User()
    @Published var userLoggedIn = Auth.auth().currentUser != nil
    var handle: AuthStateDidChangeListenerHandle?
    
    @Published var userDocLoaded = false
    
    init(){
        loadUserProfile()
        listenToAuthChanges()
    }
    
    // TODO: change to snapshot listener later
    func loadUserProfile(){
        if let user = Auth.auth().currentUser, let uid = user.uid as String?{
            db.collection("users").document(uid).getDocument { (docSnap, err) in
                if err != nil{
                    print("Error getting user profile.")
                }
                if let doc = docSnap{
                    print("GOT THIS USER")
                    self.thisUser.docToObject(doc: doc)
                    self.userDocLoaded = true
                }
            }
        }
    }
    
    func updateUserProfile(user: User) {
        if let id = Auth.auth().currentUser?.uid {
            do {
                let _ = try db.collection("users").document(id).setData(from: user)
                loadUserProfile()
            }
            catch {
                print("Unable to encode task: \(error.localizedDescription)")
            }
        }
    }
    
    func listenToAuthChanges () {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in // monitor authentication changes using firebase
            if let _ = user {
                self.userLoggedIn = true
            } else {
                self.userLoggedIn = false
            }
        }
    }
}
