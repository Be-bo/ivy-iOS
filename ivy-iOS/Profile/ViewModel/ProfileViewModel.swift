//
//  ProfileViewModel.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-29.
//  Copyright © 2020 ivy. All rights reserved.
//
//  View Model combining all individual VMs for User Profile
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore



class ProfileViewModel: ObservableObject{
    
    @Published var profileRepo: ProfileRepo
    //@Published var userInfoVM: UserInfoViewModel
    @Published var postVMs = [PostViewModel]()
    @Published var eventVMs = [EventItemViewModel]()
    
    let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    
    init(uid: String){
        self.profileRepo = ProfileRepo(uid: uid)
        //self.userInfoVM = UserInfoViewModel(user: User())
        
        /*profileRepo.$userProfile.map{ user in
            UserInfoViewModel(user: self.profileRepo.userProfile)
        }
        .assign(to: \.userInfoVM, on: self)
        .store(in: &cancellables)*/
        
        profileRepo.$posts.map { posts in
            posts.map { post in
                PostViewModel(post: post)
            }
        }
        .assign(to: \.postVMs, on: self)
        .store(in: &cancellables)
        
        profileRepo.$events.map {events in
            events.map{event in
                EventItemViewModel(event: event)
            }
        }
        .assign(to: \.eventVMs, on: self)
        .store(in: &cancellables)
    }
    
    
    // MARK: Membership Functions
    func requestMembership(uid : String?){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(uid ?? "").updateData([
                "request_ids": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func cancelRequest(uid : String?){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(uid ?? "").updateData([
                "request_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func leaveOrganization(uid : String?){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(uid ?? "").updateData([
                "member_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
}
