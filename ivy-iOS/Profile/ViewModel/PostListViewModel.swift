//
//  PostListViewModel.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-21.
//  Copyright © 2020 ivy. All rights reserved.
//

import FirebaseStorage
import Foundation
import Firebase
import Combine

class PostListViewModel: ObservableObject {
    
    @Published var posts = [Post]()
    @Published var postsLoaded = false
    
    var user_id: String
    var uni_domain: String
    
    let db = Firestore.firestore()
    
    init(user_id: String, uni_domain: String, limit: Int) {
        self.user_id = user_id
        self.uni_domain = uni_domain
        loadPosts(limit: limit)
    }
    
    func loadPosts(limit: Int) {
        let postsPath = "universities/\(uni_domain)/posts"
        
        // MARK: Robert
//        db.collection(postsPath)
//            .whereField("author_id", isEqualTo: user_id as Any)
//            .order(by: "creation_millis", descending: true)
//            .limit(to: limit)
//            .addSnapshotListener { (querySnapshot, error) in
//                if let querySnapshot = querySnapshot {
//                    self.posts = querySnapshot.documents.compactMap { document in
//                        do {
//                            if (document.get("is_event") != nil && document.get("is_event") as! Bool) {
//                                let x = try document.data(as: Post.self)
//                                return x
//                            } else {
//                                let x = try document.data(as: Post.self)
//                                return x
//                            }
//                        }
//                        catch {
//                            print(error)
//                            return nil
//                        }
//                    }
//                }
//            }
    }

}
