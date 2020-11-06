//
//  PostViewModel.swift
//  ivy
//
//  Created by Zahra Ghavasieh on 2020-10-22.
//  Copyright © 2020 ivy. All rights reserved.
//
//  Currently in the process of restructuring
//  "New" version of HomePostViewModel
//  Fill in when HomePostViewModel is later deleted
//

import Foundation
import Combine
import Firebase

class PostViewModel: PostViewModel {
    
    @Published var post_new: Post_new
    private var cancellables = Set<AnyCancellable>()
    
    init(post: Post_new){
        self.post_new = post
        super.init(post: post.convertNewToOld())
        
        $post_new.compactMap { post in
            post.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}
