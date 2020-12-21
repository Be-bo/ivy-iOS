//
//  ChatRoomRepo.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ChatRoomRepo: ObservableObject {
    
    private let db = Firestore.firestore()
    private let loadLimit = 20
    private var lastPulledDoc: DocumentSnapshot?
    
    @Published var partner = User()
    @Published var messages = [Message]()
    @Published var messagesLoaded = false
    @Published var messagesLoading = false
    
    private var chatroomID : String
    
    
    init(chatID: String, userID: String) {
        self.chatroomID = chatID
        loadMember(userID)
        loadMessages(start: true)
    }
    
    
    // Load the other member
    func loadMember(_ userID: String){
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
    func loadMessages(start: Bool = false) {
        messagesLoading = true
        
        if start {
            messagesLoaded = false
            messages = [Message]()
        }
        
        // Build query
        var query = db.collection(Message.messagesPath(chatroomID: chatroomID))
            .order(by: "time_stamp", descending: true)
            
        if (lastPulledDoc != nil && !start) {
            query = query.start(afterDocument: lastPulledDoc!).limit(to: loadLimit)
        }
        else { // Load only latest message
            query = query.limit(to: 1)
        }
        
        query.addSnapshotListener { (QuerySnapshot, error) in
                if error != nil {
                    print(error!)
                    self.messagesLoaded = true
                }
                else if let snapshot = QuerySnapshot {
                    snapshot.documentChanges.forEach { diff in
                        if let msg = try? diff.document.data(as: Message.self) {
                            if (diff.type == .added){
                                self.messages.append(msg)
                            }
                            else if let i = self.messages.firstIndex(of: msg) {
                                if (diff.type == .modified){
                                    self.messages[i] = msg
                                }
                                else if (diff.type == .removed){
                                    self.messages.remove(at: i)
                                }
                            }
                        }
                    }
                    self.messagesLoaded = true
                }
                self.messagesLoading = false
            }
    }
}
