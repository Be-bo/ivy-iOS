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
    var listener: ListenerRegistration?
    
    
    init() {}
    
    func loadPosts (limit: Int, uni_domain: String, user_id: String) {
        
        postVMs = [HomePostViewModel]() //TODO: quick and dirty
        eventVMs = [EventItemViewModel]()
        
        if (uni_domain == "" || user_id == "") {
            print("This user not loaded yet! Cannot load posts for profile")
            postsLoaded = true
            return
        }
        
        if (listener != nil) {
            print("posts already loaded...")
            postsLoaded = true
            return
        }
        
        let postsPath = "universities/\(uni_domain)/posts"
        
        print("load posts")
        
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
        listener = db.collection(postsPath)
            .whereField("author_id", isEqualTo: user_id as Any)
            .order(by: "creation_millis", descending: true)
            //.limit(to: limit) //TODO: apply pagination later
            .addSnapshotListener { (querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        print("attempting to add")
                        if (currentDoc.get("is_event") != nil && currentDoc.get("is_event") as! Bool) {
                            let newEvent = Event()
                            newEvent.docToObject(doc: currentDoc)
                            var dontAdd = false
                            for eventVM in self.eventVMs{
                                if(eventVM.event.id == newEvent.id){
                                    dontAdd = true
                                    break
                                }
                            }
                            if(!dontAdd){
                                self.eventVMs.append(EventItemViewModel(event: newEvent))
                            }
                        }
                        else {
                            let newPost = Post()
                            newPost.docToObject(doc: currentDoc)
                            var dontAdd = false
                            for postVM in self.postVMs{
                                if(postVM.post.id == newPost.id){
                                    dontAdd = true
                                    break
                                }
                            }
                            if(!dontAdd){
                                self.postVMs.append(HomePostViewModel(post: newPost))
                            }
                        }
                    }
                    self.postsLoaded = true
                }
        }
    }
    
    func removeListener(){ //method to remove the user profile realtime listener
        if let listReg = listener {
            listReg.remove()
        }
    }

}
