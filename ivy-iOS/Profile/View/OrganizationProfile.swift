//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import Firebase


struct OrganizationProfile: View {
    var thisUserIsOrg: Bool
    let db = Firestore.firestore()
    @ObservedObject var userRepo: UserRepo
    @ObservedObject var postListVM : PostListViewModel
    @State var editProfile = false
    @State var seeMemberRequests = false
    @State var selection : Int? = nil
    
    
    init(userRepo: UserRepo, postListVM: PostListViewModel, thisUserIsOrg: Bool) {
        self.userRepo = userRepo
        self.postListVM = postListVM
        self.thisUserIsOrg = thisUserIsOrg
    }
    
    init(userRepo: UserRepo, uni_domain: String, user_id: String, thisUserIsOrg: Bool) {
        self.userRepo = userRepo
        self.postListVM = PostListViewModel()
        self.thisUserIsOrg = thisUserIsOrg
        self.postListVM.loadPosts(
            limit: Constant.PROFILE_POST_LIMIT_ORG,
            uni_domain: uni_domain,
            user_id: user_id)
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
                            // MARK: Membership Buttons
                            if Auth.auth().currentUser != nil && userRepo.user.id != Auth.auth().currentUser!.uid{ //user had to be logged in and not be viewing themselves 3rd party
                                
                                // MARK: Student Requesting Buttons
                                if(!userRepo.user.member_ids.contains(Auth.auth().currentUser!.uid)){ //viewing user not a member
                                    if(userRepo.user.request_ids.contains(Auth.auth().currentUser!.uid)){ //viewing user already requested membership
                                        Button(action: {
                                            self.cancelRequest()
                                        }){
                                            Text("Cancel Join Reqest")
                                        }
                                    }else{ //neither a mem nor a req -> can request membership
                                        Button(action: {
                                            self.requestMembership()
                                        }){
                                            Text("Request Membership")
                                        }
                                    }
                                }else{ //viewing user is a member
                                    Button(action: {
                                        self.leaveOrganization()
                                    }){
                                        Text("Leave Organization")
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                
                // MARK: Members
                if(userRepo.user.member_ids.count > 0){
                    MemberListRow(thisUserIsOrg: self.thisUserIsOrg, memberIds: userRepo.user.member_ids, orgId: userRepo.user.id ?? "", userIsOrg: false).padding(.top, 20).padding(.bottom, 10)
                }
                
                
                // MARK: Member Requests
                if(userRepo.user.request_ids.count > 0 && Auth.auth().currentUser != nil && userRepo.user.id == Auth.auth().currentUser!.uid){
                    MemberListRow(thisUserIsOrg: self.thisUserIsOrg, memberIds: userRepo.user.request_ids, orgId: userRepo.user.id ?? "", titleText: "Member Requests", userIsOrg: false).padding(.top, 20).padding(.bottom, 20)
                }
                

                
                // MARK: Posts
                if (postListVM.postsLoaded == true) {
                    VStack {
                            
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
                                    ProfileEventItemView(thisUserIsOrg: self.thisUserIsOrg, eventVM: eventVM)
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
                                    ProfilePostItemView(postVM: postVM, thisUserIsOrg: self.thisUserIsOrg)
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
                    Spacer()
                }
                else {
                    LoadingSpinner().frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight, alignment: .center)   // TODO: quick and dirty
                }
            }
            .padding(.horizontal)
            .onAppear(perform: {
                if(!self.userRepo.userDocLoaded){ //if not loaded, start listening again
                    self.userRepo.loadUserProfile()
                }
                if (!self.postListVM.postsLoaded){ // start listening if not loaded yet
                    self.postListVM.loadPosts(
                        limit: Constant.PROFILE_POST_LIMIT_ORG,
                        uni_domain: self.userRepo.user.uni_domain,
                        user_id: self.userRepo.user.id ?? "")
                }
            })
            .onDisappear { //stop listening to realtime updates
                    self.userRepo.removeListener()
                    self.postListVM.removeListener()
            }
        }
    }
    
    
    
    
    // MARK: Membership Functions
    func requestMembership(){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(userRepo.user.id ?? "").updateData([
                "request_ids": FieldValue.arrayUnion([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func cancelRequest(){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(userRepo.user.id ?? "").updateData([
                "request_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
    
    func leaveOrganization(){
        if(Auth.auth().currentUser != nil){
            db.collection("users").document(userRepo.user.id ?? "").updateData([
                "member_ids": FieldValue.arrayRemove([Auth.auth().currentUser!.uid])
            ])
        }
    }
}






