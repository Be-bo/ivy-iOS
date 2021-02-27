//
//  QuadRepo.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-11-19.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Citations:
//  https://stackoverflow.com/questions/46798981/firestore-how-to-get-random-documents-in-a-collection
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class QuadRepo: ObservableObject {
    
    let db = Firestore.firestore()
    let loadLimit = 15 
    var lastPulledDoc: DocumentSnapshot?
    var blackList = [String]()              // User Ids to not fetch
    
    @Published var users = [User]()
    @Published var usersLoaded = false  // Chack if all users loaded
    @Published var usersLoading = false // Check if already fetching a batch
    
    
    
    init(thisUser: User) {
        
        // Create single BlackList
        self.blackList.append(thisUser.id)   // Don't fetch this user
        if let blocked = thisUser.blocked_users {
            self.blackList.append(contentsOf: blocked)
        }
        if let blocking = thisUser.blockers {
            self.blackList.append(contentsOf: blocking)
        }
        if let messaging = thisUser.messaging_users {
            self.blackList.append(contentsOf: messaging)
        }
        
        self.loadUsers(start: true)
    }
    
    
    //TODO: fetch randomly??
    // Paginated fetch users
    func loadUsers(start: Bool = false) {
        self.usersLoading = true
        
        if start {
            usersLoaded = false
            users = [User]()
        }
        
        // Build query
        // where(notIn:) has a limit of 10...
        var query = db.collection("users")
            .whereField("uni_domain", isEqualTo: Utils.getCampusUni())
            .limit(to: loadLimit)
            
        // Fetch next batch if this is not the first
        if (lastPulledDoc != nil && !start) {
            query = query.start(afterDocument: lastPulledDoc!)
        }
        
        query.getDocuments{ (QuerySnapshot, error) in
            if error != nil {
                print(error!)
                self.usersLoaded = true
            }
            else if let querSnap = QuerySnapshot {
                
                self.users.append(contentsOf: querSnap.documents.compactMap { document in
                    if (self.blackList.contains(document.documentID)){
                        return nil // Exclude users in blacklist
                    }
                    return try? document.data(as: User.self)
                })
                if !querSnap.isEmpty {
                    self.lastPulledDoc = querSnap.documents[querSnap.documents.count-1]
                }
                
                // Did we pull all users?
                if (querSnap.documents.count < self.loadLimit) {
                    self.usersLoaded = true
                }
                else if (self.users.isEmpty){ // Load next batch if first batch was all filtered out
                    self.loadUsers()
                }
            }
            self.usersLoading = false
        }
    }
}
