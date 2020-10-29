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
        listenToAuthChanges()
    }
    
    override func loadUserProfile(){
        if let user = Auth.auth().currentUser, let uid = user.uid as String?{
            loadProfile(userid: uid)
        }
    }
    
    func listenToAuthChanges () {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in // monitor authentication changes using firebase
            if user != nil/* && user!.isEmailVerified */{
                self.login()
            }
            else {
                self.userLoggedIn = false
                self.user = User_new()
            }
        }
    }
    
    func login() {
        if (Auth.auth().currentUser != nil /* && Auth.auth().currentUser!.isEmailVerified*/) {
            self.userLoggedIn = true
            self.loadUserProfile()
        }
    }
}
