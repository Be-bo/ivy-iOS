//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI


struct OrganizationProfile: View {
    
    @ObservedObject var userRepo: UserRepo
    @ObservedObject var postListVM : PostListViewModel
    @State var editProfile = false
    @State var seeMemberRequests = false
    @State var selection : Int? = nil
    
    
    init(userRepo: UserRepo, postListVM: PostListViewModel) {
        self.userRepo = userRepo
        self.postListVM = postListVM
    }
    
    init(userRepo: UserRepo, uni_domain: String, user_id: String) {
        self.userRepo = userRepo
        self.postListVM = PostListViewModel(
            limit: Constant.PROFILE_POST_LIMIT_ORG,
            uni_domain: uni_domain,
            user_id: user_id
        )
    }
    
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                // MARK: Header
                HStack {
                    
                    
                    // MARK: Profile Image
                    FirebaseImage(
                        path: userRepo.user.profileImagePath(),
                        placeholder: Image(systemName: "person.crop.circle.fill"),
                        width: 150,
                        height: 150,
                        shape: Circle()
                    ).padding(.trailing, 10)
                    
                    
                    // MARK: Profile Info
                    VStack (alignment: .leading){
                        Text(userRepo.user.name).padding(.bottom, 10)
                        if(userRepo.user.member_ids.count == 1){
                            Text("\(userRepo.user.member_ids.count) Member").padding(.bottom, 10)
                        }else{
                            Text("\(userRepo.user.member_ids.count) Members").padding(.bottom, 10)
                        }
                        
                        if userRepo is ThisUserRepo { // check if this is 3rd person user
                        
    //                        Button(action: {
    //                            self.seeMemberRequests.toggle()
    //                        }){
    //                            Text("Member Requests (\(userRepo.user.request_ids.count))").sheet(isPresented: $seeMemberRequests){
    //                                SeeAllUsers()
    //                            }
    //                        }.padding(.bottom, 10)
                            
                            Button(action: {
                                self.editProfile.toggle()
                            }){
                                Text("Edit").sheet(isPresented: $editProfile){
                                    EditOrganizationProfile(userProfile: self.userRepo.user, nameInput: self.userRepo.user.name)
                                }
                            }.padding(.bottom, 10)
                        }
                        else {
                            // MARK: TODO: JOIN BUTTON
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                
                
                // MARK: Bembers
                if(userRepo.user.member_ids.count > 0){
                    MemberListRow(memberIds: userRepo.user.member_ids).padding(.top, 20).padding(.bottom, 10)
                }
                
                
                // MARK: Bember Requests
                if(userRepo.user.request_ids.count > 0){
                    MemberListRow(memberIds: userRepo.user.request_ids, titleText: "Member Requests").padding(.top, 20).padding(.bottom, 20)
                }
                
                
                
                
                // MARK: Posts
                VStack() {
                    if (postListVM.postsLoaded == true) {
                        
                        // EVENTS
                        if (postListVM.eventVMs.count > 0) {
                            HStack {
                                Text("Events")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.postListVM.eventVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                            ) //{ geo in
                                { eventVM in
                                    ProfileEventItemView(eventVM: eventVM)
                                }
                            //}
                        }
                        
                        // POSTS
                        if (postListVM.postVMs.count > 0) {
                            HStack {
                                Text("Posts")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.postListVM.postVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                            ) //{ geo in
                                { postVM in
                                    ProfilePostItemView(postVM: postVM)
                                }
                            //}
                        }
                        
                        else if postListVM.eventVMs.count == 0 {
                            Spacer()
                            Text("No Posts yet!")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(alignment: .center)
                        }
                    }
                    else {
                        Spacer()
                        LoadingSpinner()
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
}




// MARK: Bus Views


