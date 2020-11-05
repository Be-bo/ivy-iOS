//
//  UserRepo.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-25.
//  Copyright © 2020 ivy. All rights reserved.
//
// A generic User Repository
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase


class UserRepo: ObservableObject {
    
    @Published var user : User
    @Published var userDocLoaded = false
    var listenerRegistration: ListenerRegistration?
    @Published var thisUserIsOrg = false
    
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
        loadProfile(userid: user.id)
    }
    

/* FIREBASE functions used by children */
    
    func loadProfile(userid: String) {
        if(userid != ""){
            listenerRegistration = db.collection("users").document(userid).addSnapshotListener { (docSnap, err) in
                if err != nil{
                    print("Error getting user profile.")
                }
                if let doc = docSnap{
                    
                    do { try self.user = doc.data(as: User.self)! }
                    catch { print("Could not load User for UserRepo: \(error)") }
                    
                    //self.user.docToObject(doc: doc)
                    self.userDocLoaded = true
                    
                    if Auth.auth().currentUser != nil, Auth.auth().currentUser!.uid == self.user.id{ //want to show logged in user's uni by default + saving some values we need locally
                        Utils.setCampusUni(newUni: self.user.uni_domain)
                        Utils.setIsThisUserOrg(isOrg: self.user.is_organization)
                        Utils.setThisUserName(name: self.user.name)
                    }
                }
            }
        }
    }
    
    func removeListener(){ //method to remove the user profile realtime listener
        if let listReg = listenerRegistration{
            listReg.remove()
        }
    }
}

