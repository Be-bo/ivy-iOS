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
    @Published var homePostsVMs = [PostViewModel]()
    private var cancellables = Set<AnyCancellable>()
    var currentUni = Utils.getCampusUni()
    
    init(){
        homeRepo.$homePosts.map {posts in
            posts.map{post in
                PostViewModel(post: post)
            }
        }
        .assign(to: \.homePostsVMs, on: self)
        .store(in: &cancellables)
    }
    
    func refresh(){
        homeRepo.refresh()
    }
    
    func reloadData(){
        homeRepo.startFetchingPosts()
    }
}
