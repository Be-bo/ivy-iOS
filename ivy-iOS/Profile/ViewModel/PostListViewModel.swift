//
//  PostListViewModel.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import FirebaseStorage
import Foundation
import SwiftUI
import Firebase
import Combine

class PostListViewModel: ObservableObject {
    
    @Published var postVMs = [HomePostViewModel]()
    @Published var eventVMs = [EventItemViewModel]()    //TODO: quick and dirty
    @Published var postsLoaded = false
        
    let db = Firestore.firestore()
    
    
    init (limit: Int, uni_domain: String, user_id: String) {
        let postsPath = "universities/\(uni_domain)/posts"
        if (uni_domain == "" || user_id == "") {
            print("This user not loaded yet! Cannot load posts for profile")
            postsLoaded = true
            return
        }
        
        /*db.collection(postsPath)
            .whereField("author_id", isEqualTo: user_id as Any)
            .order(by: "creation_millis", descending: true)
            .limit(to: limit)
            .addSnapshotListener { (querySnapshot, error) in
                if let querySnapshot = querySnapshot {
                    self.posts = querySnapshot.documents.compactMap { document in
                        do {
                            if (document.get("is_event") != nil && document.get("is_event") as! Bool) {
                                let x = try document.data(as: Event.self)
                                return x
                            } else {
                                let x = try document.data(as: Post.self)
                                return x
                            }
                        }
                        catch {
                            print(error)
                            return nil
                        }
                    }
                }
            }*/
        
        // TODO: this is quick and dirty. must retrieve docs as objects later and apply pagination
        db.collection(postsPath)
            .whereField("author_id", isEqualTo: user_id as Any)
            .order(by: "creation_millis", descending: true)
            //.limit(to: limit) //TODO: apply pagination later
            .addSnapshotListener { (querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        if (currentDoc.get("is_event") != nil && currentDoc.get("is_event") as! Bool) {
                            let newEvent = Event()
                            newEvent.docToObject(doc: currentDoc)
                            self.eventVMs.append(EventItemViewModel(event: newEvent))
                        }
                        else {
                            let newPost = Post()
                            newPost.docToObject(doc: currentDoc)
                            self.postVMs.append(HomePostViewModel(post: newPost))
                        }
                    }
                    self.postsLoaded = true
                    print("\(self.postVMs.count) posts and \(self.eventVMs.count) events were uploaded from database")
                }
        }
    }

}
