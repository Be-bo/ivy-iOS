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

class ThisUserRepo: UserRepo {
    
    @Published var userLoggedIn = Auth.auth().currentUser != nil
    var handle: AuthStateDidChangeListenerHandle?
    
    
    override init(){
        super.init()
        loadUserProfile()
        listenToAuthChanges()
    }
    
    // TODO: change to snapshot listener later
    override func loadUserProfile(){
        if let user = Auth.auth().currentUser, let uid = user.uid as String?{
            loadProfile(userid: uid)
        }
    }
    
    override func updateUserProfile(updatedUser: User) {
        if let id = Auth.auth().currentUser?.uid {
            updateProfile(userid: id, updatedUser: updatedUser)
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
