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

class HomePostViewModel: ObservableObject, Identifiable{
    let db = Firestore.firestore()
    @Published var post: Post
    @Published var pinnedEvent = Event()
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(post: Post){
        self.post = post
        $post.compactMap { post in
            post.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
        
        if(post.pinned_id != "" && post.pinned_id != "nothing"){
            db.collection("universities").document(Utils.getCampusUni()).collection("posts").document(post.pinned_id).getDocument{(docsnap, error) in
                if error != nil{
                    print("Failed to load pinned event for post")
                }
                if docsnap != nil{
                    self.pinnedEvent.docToObject(doc: docsnap!)
                }
            }
        }
    }
}
