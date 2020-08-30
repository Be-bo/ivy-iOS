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
    
    init(uid: String){
        self.userId = uid
        self.loadData(alsoLoadPosts: true)
    }
    
    func loadData(alsoLoadPosts: Bool){
        db.collection("users").document(self.userId).getDocument { (docSnap, err) in
            if err != nil{
                print("Error loading user profile in profile repo.")
                return
            }
            if (docSnap) != nil{
                self.userProfile.docToObject(doc: docSnap!)
                if alsoLoadPosts{
                    self.loadPosts()
                    self.loadEvents()
                }
            }
        }
    }
    
    func loadPosts(){
        db.collection("universities").document(self.userProfile.uni_domain).collection("posts").whereField("author_id", isEqualTo: self.userProfile.id!).whereField("is_event", isEqualTo: false).order(by: "creation_millis", descending: true).getDocuments { (querySnap, error) in
            if error != nil{
                print("Error loading posts in profile repo.")
                return
            }
            if let snapshot = querySnap{
                for currentDoc in snapshot.documents{
                    let newPost = Post()
                    newPost.docToObject(doc: currentDoc)
                    self.posts.append(newPost)
                }
            }
        }
    }
    
    func loadEvents(){
        db.collection("universities").document(self.userProfile.uni_domain).collection("posts").whereField("author_id", isEqualTo: self.userProfile.id!).whereField("is_event", isEqualTo: true).order(by: "creation_millis", descending: true).getDocuments { (querySnap, error) in
            if error != nil {
                print("Error loading events in profile repo.")
                return
            }
            if let snapshot = querySnap{
                for currentDoc in snapshot.documents{
                    let newEvent = Event()
                    newEvent.docToObject(doc: currentDoc)
                    self.events.append(newEvent)
                }
            }
        }
    }
}
