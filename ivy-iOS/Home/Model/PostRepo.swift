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
    let db = Firestore.firestore()
    @Published var homePosts = [Post]()
    
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
                }
        }
    }
    
}
