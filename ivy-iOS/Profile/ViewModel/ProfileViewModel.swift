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
    @Published var userEventVMs = [EventItemViewModel]() {
        willSet {
            print("EVENT VMs ARRAY WILL CHANGE!!! Size: \(userEventVMs.count)")
        }
        didSet {
            print("EVENT VMs ARRAY CHANGED!!! Size: \(userEventVMs.count) \n")
        }
    }
    @Published var userPostVMs = [HomePostViewModel]() {
        willSet {
            print("POST VMs ARRAY WILL CHANGE!!! Size: \(userPostVMs.count)")
        }
        didSet {
            print("POST VMs ARRAY CHANGED!!! Size: \(userPostVMs.count) \n")
        }
    }
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
