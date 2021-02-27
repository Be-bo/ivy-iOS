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
                self.user = User()
            }
        }
    }
    
    func login() {
        if (Auth.auth().currentUser != nil /* && Auth.auth().currentUser!.isEmailVerified*/) {
            self.userLoggedIn = true
            self.loadUserProfile()
        }
    }
    
    // Block user -> add to your blocked list and their blocking list
    func blockUser(userID: String) {
        
        // Update block lists
        db.document(user.getUserPath())
            .updateData(["blocked_users" : FieldValue.arrayUnion([userID])])
        db.document(Utils.getUserPath(userId: userID))
            .updateData(["blockers" : FieldValue.arrayUnion([user.id])])
        
        // Remove any chatrooms
        if let isMessaging = user.messaging_users?.contains(userID) {
            if isMessaging {
                
                // Remove from messaging lists
                db.document(user.getUserPath())
                    .updateData(["messaging_users" : FieldValue.arrayRemove([userID])])
                db.document(Utils.getUserPath(userId: userID))
                    .updateData(["messaging_users" : FieldValue.arrayRemove([user.id])])
                
                // Remove chatrooms
                db.collection("conversations")
                    .whereField("members", arrayContains: user.id).getDocuments { (querySnap, err) in
                        if (err != nil || querySnap == nil || querySnap!.isEmpty) {
                            return
                        }
                        querySnap!.documents.forEach { doc in
                            if let room = try?  doc.data(as: Chatroom.self) {
                                if room.members.contains(userID) {
                                    self.leaveChatroom(room: room, thisUserID: self.user.id)
                                }
                            }
                        }
                    }
            }
        }
    }
    
    private func leaveChatroom(room: Chatroom, thisUserID: String){
        let roomPath = db.document(room.getPath())
        roomPath.updateData(["members" : FieldValue.arrayRemove([thisUserID])]) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            roomPath.getDocument { (doc, err1) in
                if let err1 = err1 {
                    print(err1.localizedDescription)
                }
                else if let doc = doc {
                    if let room = try? doc.data(as: Chatroom.self) {
                        // Delete if empty, else send a message saying you left chatroom
                        if room.members.isEmpty {
                            roomPath.delete()
                        } else {
                            self.sendMessage(
                                chatroomID: room.id,
                                msg: Message(author: self.user.id, text: "\(self.user.name) left the Conversation."))
                        }
                    }
                }
            }
        }
    }
    
    private func sendMessage(chatroomID: String, msg: Message){
        let _ = try! db.document(msg.getPath(chatroomID: chatroomID))
            .setData(from: msg) { (err) in
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
            }
    }
    
    func unblockUser(userID: String) {
        db.document(user.getUserPath())
            .updateData(["blocked_users" : FieldValue.arrayRemove([userID])])
        db.document(Utils.getUserPath(userId: userID))
            .updateData(["blockers" : FieldValue.arrayRemove([user.id])])
    }
}
