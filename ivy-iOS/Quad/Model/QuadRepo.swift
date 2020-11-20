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
    let loadLimit = 10
    var lastPulledDoc: DocumentSnapshot?
    
    @Published var users = [User]()
    @Published var usersLoaded = false
    
    
    init() {
        self.loadUsers(start: true)
    }
    
    
    //TODO: fetch randomly
    //TODO: don't fetch blacklist or added users
    // Paginated fetch users
    func loadUsers(start: Bool = false) {
        
        if start {
            usersLoaded = false
            users = [User]()
        }
        
        // Build query
        var query = db.collection("universities").document(Utils.getCampusUni()).collection("users")
            .order(by: "id")
            
        // Fetch next batch if this is not the first
        if (lastPulledDoc != nil && !start) {
            query = query.start(afterDocument: lastPulledDoc!)
        }
        
        query.limit(to: loadLimit).getDocuments{ (QuerySnapshot, error) in
            if error != nil {
                print(error!)
                self.usersLoaded = true
                return
            }
            if let querSnap = QuerySnapshot {
                self.users.append(contentsOf: querSnap.documents.compactMap { document in
                    return try? document.data(as: User.self)
                })
                if !querSnap.isEmpty {
                    self.lastPulledDoc = querSnap.documents[querSnap.documents.count-1]
                }
                
                // Did we pull all users?
                if (querSnap.documents.count < self.loadLimit) {
                    self.usersLoaded = true
                }
            }
            
        }
        
    }
}
