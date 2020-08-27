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
    let creationMillis = Utils.getCurrentTimeInMillis()
    let db = Firestore.firestore()
    @Published var homePosts = [Post]()
    @Published var postsLoaded = false
    
    init() {
        print("calling load posts")
        self.loadHomePosts()
    }
    
    func loadHomePosts(){
        db.collection("universities").document(Utils.getCampusUni()).collection("posts").whereField("is_event", isEqualTo: false).order(by: "creation_millis", descending: true).getDocuments{(querySnapshot, error) in
                if let querSnap = querySnapshot{
                    for currentDoc in querSnap.documents{
                        let newPost = Post()
                        newPost.docToObject(doc: currentDoc)
                        self.homePosts.append(newPost)
                    }
                    self.postsLoaded = true
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
                        self.homePosts.insert(newPost, at: 0)
                    }
                    self.postsLoaded = true
                }
        }
    }
    
}
