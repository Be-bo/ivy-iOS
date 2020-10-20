//
//  ProfileRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ProfileRepo: ObservableObject{
    
    let creationMillis = Utils.getCurrentTimeInMillis()
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
        db.collection("users").document(self.userId).getDocument { (docSnap, err) in
            if err != nil{
                print("Error loading user profile in profile repo.")
                return
            }
            if (docSnap) != nil{
                self.userProfile.docToObject(doc: docSnap!)
                self.loadPosts(start: true)
                self.loadEvents(start: true)
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
            //posts = [Post]() // reset list (maybe for reloading later)
        }
        
        var query =
            db.collection("universities").document(self.userProfile.uni_domain).collection("posts")
            .whereField("author_id", isEqualTo: self.userProfile.id!)
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
                for currentDoc in snapshot.documents{
                    let newPost = Post()
                    newPost.docToObject(doc: currentDoc)
                    self.posts.append(newPost)
                }
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
            //print("\nResetting Events list")
            eventsLoaded = false
            //events = [Event]() // reset list (maybe for reloading later)
        }
        
        var query =
            db.collection("universities").document(self.userProfile.uni_domain).collection("posts")
            .whereField("author_id", isEqualTo: self.userProfile.id!)
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
                
                for currentDoc in snapshot.documents{
                    let newEvent = Event()
                    newEvent.docToObject(doc: currentDoc)
                    self.events.append(newEvent)
                }
                
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
    
    
    
    
    // MARK: Membership Functions
    func requestMembership(uid : String?){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(uid ?? "").updateData([
                "request_ids": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func cancelRequest(uid : String?){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(uid ?? "").updateData([
                "request_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func leaveOrganization(uid : String?){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(uid ?? "").updateData([
                "member_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
}
