//
//  HomeTabViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class HomeTabViewModel: ObservableObject {
    @Published var homeRepo = PostRepo()
    @Published var homePostsVMs = [HomePostViewModel]()
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        homeRepo.$homePosts.map {posts in
            posts.map{post in
                HomePostViewModel(post: post)
            }
        }
        .assign(to: \.homePostsVMs, on: self)
        .store(in: &cancellables)
    }
}