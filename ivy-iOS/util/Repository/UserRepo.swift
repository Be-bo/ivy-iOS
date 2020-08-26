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
import Firebase


class UserRepo: ObservableObject {
    
    @Published var user : User
    @Published var userDocLoaded = false
    var listenerRegistration: ListenerRegistration?
    
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
    

/* FIREBASE functions used by children */
    
    // TODO: change to snapshot listener later
    func loadProfile(userid: String) {
        removeListener()
        listenerRegistration = db.collection("users").document(userid).addSnapshotListener { (docSnap, err) in
            if err != nil{
                print("Error getting user profile.")
            }
            if let doc = docSnap{
                self.user.docToObject(doc: doc)
                self.userDocLoaded = true
            }
        }
    }
    
    func removeListener(){ //method to remove the user profile realtime listener
        if let listReg = listenerRegistration{
            listReg.remove()
        }
    }
}

