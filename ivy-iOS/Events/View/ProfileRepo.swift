//
//  ProfileRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Point of contact for Firebase and User Profile
//  This Repo will load all entities needed for User Profile from Firebase
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProfileRepo: ObservableObject{
    
    let db = Firestore.firestore()
    var userId = ""
    @Published var userProfile = User()
    @Published var posts = [Post]()
    @Published var events = [Event]()
    
    // Pagination
    let loadLimit = 9 // Must be divisible by 3! (use 3 for testing)
    var lastPulledPostDoc: DocumentSnapshot?
    var lastPulledEventDoc: DocumentSnapshot?
    @Published var postsLoaded = false
    @Published var eventsLoaded = false
    
    
    init(uid: String){
        self.userId = uid
        if (!self.userId.isEmpty) {
            db.collection("users").document(self.userId).getDocument { (docSnap, err) in
                if err != nil{
                    print("Error loading user profile in profile repo. \(err!)")
                    return
                }
                if (docSnap) != nil{
                    
                    do { try self.userProfile = docSnap!.data(as: User.self)! }
                    catch { print("Could not load User for ProfileRepo: \(error)") }
                                    
                    self.loadPosts(start: true)
                    self.loadEvents(start: true)
                }
            }
        }
    }
    
    // Paginated: fetch posts (start = true if this is first batch)
    func loadPosts(start: Bool = false){
        if userProfile.uni_domain.isEmpty {
            print("ProfileRepo: user profile not loaded yet!")
            return
        }
                
        if start {
            postsLoaded = false
            posts = [Post]() // reset list (maybe for reloading later)
        }
        
        var query =
            db.collection("universities").document(Utils.getCampusUni()).collection("posts")
            .whereField("author_id", isEqualTo: self.userProfile.id)
            .whereField("is_event", isEqualTo: false)
            .order(by: "creation_millis", descending: true)
            
        // Fetch next batch if this is not the first
        if (lastPulledPostDoc != nil && !start) {
            query = query.start(afterDocument: lastPulledPostDoc!)
        }
            
        query.limit(to: loadLimit).getDocuments { (querySnap, error) in
            if error != nil{
                print("Error loading posts in profile repo. \(error!)")
                self.postsLoaded = true
                return
            }
            
            if let snapshot = querySnap {
                
                self.posts.append(contentsOf: snapshot.documents.compactMap { doc in
                    do {
                        let x = try doc.data(as: Post.self)
                        return x
                    }
                    catch { print("ProfileRepo.loadPosts: \(error)") }
                    return nil
                })
                
                if !snapshot.isEmpty {
                    self.lastPulledPostDoc = snapshot.documents[snapshot.documents.count-1]
                }
                
                // Did we pull all the events?
                if (snapshot.documents.count < self.loadLimit) {
                    self.postsLoaded = true
                }
            }
        }
    }
    
    // Paginated: fetch events (start = true if this is first batch)
    func loadEvents(start: Bool = false){
        if userProfile.uni_domain.isEmpty {
            print("ProfileRepo: use profile not loaded yet!")
            return
        }
        
        if start {
            eventsLoaded = false
            events = [Event]() // reset list (maybe for reloading later)
        }
        
        var query =
            db.collection("universities").document(Utils.getCampusUni()).collection("posts")
            .whereField("author_id", isEqualTo: self.userProfile.id)
            .whereField("is_event", isEqualTo: true)
            .order(by: "creation_millis", descending: true)
         
        // Fetch next batch if this is not the first
        if (lastPulledEventDoc != nil && !start){
            query = query.start(afterDocument: lastPulledEventDoc!)
        }
            
        query.limit(to: loadLimit).getDocuments { (querySnap, error) in
            if error != nil {
                print("Error loading events in profile repo.")
                self.eventsLoaded = true
                return
            }
            if let snapshot = querySnap {
                
                self.events.append(contentsOf: snapshot.documents.compactMap { doc in
                    do {
                        let x = try doc.data(as: Event.self)
                        return x
                    } catch { print(error) }
                    return nil
                })
                
                if !snapshot.isEmpty {
                    self.lastPulledEventDoc = snapshot.documents[snapshot.documents.count-1]
                }
                    
                // Did we pull all the events?
                if (snapshot.documents.count < self.loadLimit) {
                    self.eventsLoaded = true
                }

            }
        }
    }
}
