//
//  HomeTabItemViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine
import Firebase

class PostViewModel: ObservableObject, Identifiable{
    let db = Firestore.firestore()
    @Published var post: Post_new
    @Published var pinnedEvent = Event_new()
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(post: Post_new){
        self.post = post
        $post.compactMap { post in
            post.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
        
        // Upload pinned event
        if(post.pinned_id != "" && post.pinned_id != "nothing"){
            
            db.document(Event_new.eventPath(post.pinned_id)).getDocument{(docsnap, error) in
                if error != nil{
                    print("Failed to load pinned event for post")
                }
                if let doc = docSnap {
                    do { try self.pinnedEvent = doc.data(as: Event_new.self)! }
                    catch { print("Could not load pinned Event for Post: \(error)") }
                }
            }
        }
    }
}
