//
//  ChatRoomRepo.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//


import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


class ChatRoomRepo: ObservableObject {
    
    private let db = Firestore.firestore()
    private let loadLimit = 20
    private var lastPulledDoc: DocumentSnapshot?
    private var latestMessageDoc: DocumentSnapshot?
    
    @Published var partner = User()
    @Published var messages = [Message]()
    @Published var messagesLoaded = false
    @Published var messagesLoading = false
    @Published var waitingToSend = false
    @Published var sentMsg = false

    private var chatroomID : String
    
    
    init(chatID: String, userID: String) {
        self.chatroomID = chatID
        loadMember(userID)
        loadLatestMessage()
    }
    
    
    // Load the other member
    func loadMember(_ userID: String){
        if userID.isEmpty {
            print("ChatRoomRepo.loadMember: Empty UserID")
            return
        }
        
        db.document(Utils.getUserPath(userId: userID))
            .getDocument { (docSnapshot, error) in
                
                if error != nil {
                    print(error!)
                }
                else if let doc = docSnapshot {
                    if let user = try? doc.data(as: User.self) {
                        self.partner = user
                    }
                }
            }
    }
    
    
    // Add a snapshot to latest message
    func loadLatestMessage() {
        messagesLoading = true
        messagesLoaded = false
        messages = [Message]()
        
        // Build query
        let query = db.collection(Message.messagesPath(chatroomID: chatroomID))
            .order(by: "time_stamp", descending: true)
            .limit(to: 1)

        // Add snapshot
        query.addSnapshotListener { (QuerySnapshot, error) in
                if error != nil {
                    print(error!)
                    self.messagesLoaded = true
                }
                else if let snapshot = QuerySnapshot {
                    snapshot.documentChanges.forEach { diff in
                        if let msg = try? diff.document.data(as: Message.self) {
                            if (diff.type == .added){
                                // View is fliped upside down
                                self.messages.insert(msg, at: 0)
                            }
                        } else {
                            print("ChatRoomRepo: Couldn't convert Message object! ID: \(diff.document.documentID)")
                        }
                    }
                    
                    // Update latest msg doc
                    if !snapshot.isEmpty {
                        self.latestMessageDoc = snapshot.documents[0]
                    }
                    
                    // There are no messages in room?
                    if snapshot.documents.count < 1 {
                        self.messagesLoaded = true
                    }
                }
                self.messagesLoading = false
            }
    }
    
    
    // Add a snapshot to latest message
    func loadMessages() {
        messagesLoading = true
        
        // Build query
        var query = db.collection(Message.messagesPath(chatroomID: chatroomID))
            .order(by: "time_stamp", descending: false)
            
        if (latestMessageDoc != nil) {
            query = query.end(beforeDocument: latestMessageDoc!)
        }
        
        if (lastPulledDoc != nil) {
            query = query.start(afterDocument: lastPulledDoc!).limit(to: loadLimit)
        }
        
        // Add snapshot
        query.addSnapshotListener { (QuerySnapshot, error) in
                if error != nil {
                    print(error!)
                    self.messagesLoaded = true
                }
                else if let snapshot = QuerySnapshot {
                    snapshot.documentChanges.forEach { diff in
                        if let msg = try? diff.document.data(as: Message.self) {
                            if (diff.type == .added){
                                // View is fliped upside down (slot[0] used for latest message)
                                if (self.messages.count > 0) {
                                    self.messages.insert(msg, at: 1)
                                }
                            }
                        } else {
                            print("ChatRoomRepo: Couldn't convert Message object! ID: \(diff.document.documentID)")
                        }
                    }
                    
                    // Update last pulled doc
                    if !snapshot.isEmpty {
                        self.lastPulledDoc = snapshot.documents[snapshot.documents.count - 1]
                    }
                    
                    // Did we pull all messages?
                    // if start -> less than 1? else -> less than load?
                    if snapshot.documents.count < self.loadLimit {
                        self.messagesLoaded = true
                    }
                }
                self.messagesLoading = false
            }
    }
    
    
    // Send Message
    func sendMessage(_ msg: Message) {
        waitingToSend = true
        sentMsg = false
        
        let _ = try! db.document(msg.getPath(chatroomID: chatroomID))
            .setData(from: msg) { (err) in
        
                if err != nil {
                    print(err!.localizedDescription)
                    self.waitingToSend = false
                    return
                }
                
                self.waitingToSend = false
                self.sentMsg = true
            }
    }
    
    
    // Add user to MessagingList
    func addUserToMessagingList(thisUserID: String, userID: String) {
        if (!thisUserID.isEmpty && !userID.isEmpty) {
            db.document(Utils.getUserPath(userId: thisUserID))
                .updateData(["messaging_users" : FieldValue.arrayUnion([userID])])
            db.document(Utils.getUserPath(userId: userID))
                .updateData(["messaging_users" : FieldValue.arrayUnion([thisUserID])])
        }
        else {
            print("ChatRoomRepo.addToMessagingList: empty ids")
        }
    }
    
    
    // Save Chatroom to Firebase before sending message
    func saveChatroom(room: Chatroom, msg: Message, thisUserID: String, userID: String) {
        waitingToSend = true
        sentMsg = false
        
        let _ = try! db.document(room.getPath()).setData(from: room) { (err) in
        
                if err != nil {
                    print(err!.localizedDescription)
                    self.waitingToSend = false
                    return
                }
            
                // Chatroom creation successful -> continue to next steps
                self.addUserToMessagingList(thisUserID: thisUserID, userID: userID)
                self.sendMessage(msg)
            }
    }
    
    
    // Remove Chatroom from database
    func deleteChatroom(room: Chatroom, thisUserID: String, userID: String) {
        if (thisUserID.isEmpty || userID.isEmpty){
            return
        }
        
        // Remove from messaging list
        db.document(Utils.getUserPath(userId: thisUserID))
            .updateData(["messaging_users" : FieldValue.arrayRemove([userID])])
        
        // Remove user from chatroom members. if empty list -> delete document
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
                        // Delete if empty, else do nothing
                        if room.members.isEmpty {
                            roomPath.delete()
                        }
                    }
                }
            }
        }
    }
    
    
    // Block -> remove chatroom and add to Blocked Users list
    func blockUser(room: Chatroom, thisUserID: String, userID: String) {
        if (thisUserID.isEmpty || userID.isEmpty) {
            return
        }
        
        // Add to this blocked list
        db.document(Utils.getUserPath(userId: thisUserID))
            .updateData(["blocked_users" : FieldValue.arrayUnion([userID])])
        
        // Add to their blocking list
        db.document(Utils.getUserPath(userId: userID))
            .updateData(["blockers" : FieldValue.arrayUnion([thisUserID])])
        
        // remove chatroom
        deleteChatroom(room: room, thisUserID: thisUserID, userID: userID)
    }
}
