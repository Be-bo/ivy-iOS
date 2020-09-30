//
//  HomeTabRepo.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class PostRepo: ObservableObject{
    let loadLimit = 4
    let creationMillis = Utils.getCurrentTimeInMillis()
    let db = Firestore.firestore()
    @Published var homePosts = [Post]()
    @Published var postsLoaded = false
    var lastPulledDoc: DocumentSnapshot?
    
    init() {
        self.startFetchingPosts()
    }
    
    func startFetchingPosts(){
        homePosts = [Post]()
        postsLoaded = false
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: false).order(by: "creation_millis", descending: true).limit(to: loadLimit).getDocuments{(querySnapshot, error) in
            if error != nil{
                print("Error loading first home posts")
                self.postsLoaded = true
                return
            }
            if let querSnap = querySnapshot{
                for currentDoc in querSnap.documents{
                    let newPost = Post()
                    newPost.docToObject(doc: currentDoc)
                    self.homePosts.append(newPost)
                }
                
                self.lastPulledDoc = querSnap.documents[querSnap.documents.count-1]
                if(querSnap.documents.count < self.loadLimit){ //if less docs than limit, we're at the end of the collection
                    self.postsLoaded = true
                }
            }
        }
    }
    
    func fetchBatch(){
        if let lastDoc = lastPulledDoc{
            db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: false).order(by: "creation_millis", descending: true).start(afterDocument: lastDoc).limit(to: loadLimit).getDocuments{(querySnapshot, error) in
                if error != nil{
                    print("Error loading home posts")
                    self.postsLoaded = true
                    return
                }
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newPost = Post()
                        newPost.docToObject(doc: currentDoc)
                        self.homePosts.append(newPost)
                    }
                    
                    self.lastPulledDoc = querSnap.documents[querSnap.documents.count-1]
                    if(querSnap.documents.count < self.loadLimit){ //if less docs than limit, we're at the end of the collection
                        self.postsLoaded = true
                    }
                }
            }
        }
    }
    
    func refresh(){
        postsLoaded = false
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: false)
            .whereField("creation_millis", isGreaterThan: creationMillis).order(by: "creation_millis", descending: true).getDocuments{(querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newPost = Post()
                        newPost.docToObject(doc: currentDoc)
                        var dontAdd = false
                        for currentPost in self.homePosts{
                            if(currentPost.id == newPost.id){
                                dontAdd = true
                                break
                            }
                        }
                        if(!dontAdd){
                            self.homePosts.insert(newPost, at: 0)
                        }
                    }
                }
        }
    }
    
}
