//
//  ProfileViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject{
    @Published var profileRepo: ProfileRepo
    @Published var userInfoVM: UserInfoViewModel
    @Published var userEventVMs = [EventItemViewModel]()
    @Published var userPostVMs = [HomePostViewModel]()
    private var cancellables = Set<AnyCancellable>()
    
    init(uid: String){
        self.profileRepo = ProfileRepo(uid: uid)
        self.userInfoVM = UserInfoViewModel(user: User())
        
        profileRepo.$userProfile.map{ user in
            UserInfoViewModel(user: self.profileRepo.userProfile)
        }
        .assign(to: \.userInfoVM, on: self)
        .store(in: &cancellables)
        
        profileRepo.$posts.map {posts in
            posts.map{post in
                HomePostViewModel(post: post)
            }
        }
        .assign(to: \.userPostVMs, on: self)
        .store(in: &cancellables)
        
        self.profileRepo = ProfileRepo(uid: uid)
        profileRepo.$events.map {events in
            events.map{event in
                EventItemViewModel(event: event)
            }
        }
        .assign(to: \.userEventVMs, on: self)
        .store(in: &cancellables)
    }
    
}
