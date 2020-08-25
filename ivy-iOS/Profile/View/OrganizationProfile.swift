//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI


struct OrganizationProfile: View {
    
    @ObservedObject var thisUserRepo: ThisUserRepo
    @ObservedObject var postListVM = PostListViewModel()
    @State var editProfile = false
    @State var seeMemberRequests = false
    
    
    init(thisUserRepo: ThisUserRepo) {
        self.thisUserRepo = thisUserRepo
        self.postListVM.loadPosts(
            limit: Constant.PROFILE_POST_LIMIT_STUDENT,
            uni_domain: thisUserRepo.thisUser.uni_domain,
            user_id: thisUserRepo.thisUser.id ?? ""
        )
    }
    
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                // MARK: Header
                HStack {
                    
                    
                    // MARK: Profile Image
                    FirebaseImage(
                        path: thisUserRepo.thisUser.profileImagePath(),
                        placeholder: Image(systemName: "person.crop.circle.fill"),
                        width: 150,
                        height: 150,
                        shape: Circle()
                    ).padding(.trailing, 10)
                    
                    
                    // MARK: Profile Info
                    VStack (alignment: .leading){
                        Text(thisUserRepo.thisUser.name).padding(.bottom, 10)
                        if(thisUserRepo.thisUser.member_ids.count == 1){
                            Text("\(thisUserRepo.thisUser.member_ids.count) Member").padding(.bottom, 10)
                        }else{
                            Text("\(thisUserRepo.thisUser.member_ids.count) Members").padding(.bottom, 10)
                        }
                        
//                        Button(action: {
//                            self.seeMemberRequests.toggle()
//                        }){
//                            Text("Member Requests (\(thisUserRepo.thisUser.request_ids.count))").sheet(isPresented: $seeMemberRequests){
//                                SeeAllUsers()
//                            }
//                        }.padding(.bottom, 10)
                        
                        Button(action: {
                            self.editProfile.toggle()
                        }){
                            Text("Edit").sheet(isPresented: $editProfile){
                                EditOrganizationProfile(userProfile: self.thisUserRepo.thisUser, nameInput: self.thisUserRepo.thisUser.name)
                            }
                        }.padding(.bottom, 10)
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                
                
                // MARK: Bembers
                if(thisUserRepo.thisUser.member_ids.count > 0){
                    MemberListRow(memberIds: thisUserRepo.thisUser.member_ids).padding(.top, 20).padding(.bottom, 10)
                }
                
                
                // MARK: Bember Requests
                if(thisUserRepo.thisUser.request_ids.count > 0){
                    MemberListRow(memberIds: thisUserRepo.thisUser.request_ids, titleText: "Member Requests").padding(.top, 20).padding(.bottom, 20)
                }
                
                
                
                
                // MARK: Posts
                VStack() {
                    if (postListVM.postsLoaded == true) {
                        if (postListVM.posts.count > 0) {
                            HStack{
                                Text("Posts")
                                Spacer()
                            }
                            
                            NavigationView {
                                GridView(
                                    cells: postListVM.posts,
                                    maxCol: 3
                                ) { post in
                                    Text(post.text)
                                    
                                    /*
                                     //TODO: ASK ROBERT's ipad
                                     //NavigationLink(destination: PostScreen()) {
                                     FirebaseImage(
                                     path: Utils.postPreviewImagePath(postId: post.id ?? "nil"),
                                     placeholder: AssetManager.logoWhite,
                                     width: 150,
                                     height: 150,
                                     shape: RoundedRectangle(cornerRadius: 25)
                                     )
                                     //}
                                     */
                                }
                            }
                        }
                        else {
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


