//
//  ChatRepo.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-12-10.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ChatRepo: ObservableObject {
    
    private let db = Firestore.firestore()
    private let loadLimit = 10
    private var lastPulledDoc: DocumentSnapshot?
    
    @Published var chatrooms = [Chatroom]()
    @Published var chatroomsLoaded = false
    @Published var chatroomsLoading = false
    
    private var userID : String
    
    
    init(id: String) {
        self.userID = id
        loadChatrooms(start: true)
    }
    
    
    // Add a snapshot listener to Chatrooms
    func loadChatrooms(start: Bool = false) {
        chatroomsLoading = true
        
        if start {
            chatroomsLoaded = false
            chatrooms = [Chatroom]()
        }
        
        // Build query
        var query = db.collection("conversations")
            .whereField("members", arrayContains: userID)
            
        // Fetch next batch if this is not the first
        if (lastPulledDoc != nil && !start) {
            query = query.start(afterDocument: lastPulledDoc!)
        }
        
        query.limit(to: loadLimit).addSnapshotListener { (QuerySnapshot, error) in
            if error != nil {
                print(error!)
                self.chatroomsLoaded = true
            }
            else if let snapshot = QuerySnapshot {
                snapshot.documentChanges.forEach { diff in
                    if let room = try?  diff.document.data(as: Chatroom.self) {
                        if (diff.type == .added) {
                            self.chatrooms.append(room)
                        }
                        
                        else if let i = self.chatrooms.firstIndex(of: room){
                            if (diff.type == .modified) {
                                self.chatrooms[i] = room
                            }
                            
                            if (diff.type == .removed) {
                                self.chatrooms.remove(at: i)
                            }
                        }
                    }
                }
                
                //Update last pulled Doc
                if !snapshot.isEmpty {
                    self.lastPulledDoc = snapshot.documents[snapshot.documents.count - 1]
                }
                
                // Did we pull all rooms?
                if (snapshot.documents.count < self.loadLimit && !start) {
                    self.chatroomsLoaded = true
                }
            }
            self.chatroomsLoading = false
        }
    }
}
