//
//  HomeTabItemViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class HomePostViewModel: ObservableObject, Identifiable{
    @Published var post: Post
    var id = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(post: Post){
        self.post = post
        $post.compactMap { post in
            post.id
        }
        .assign(to: \.id, on: self)
        .store(in: &cancellables)
    }
}
