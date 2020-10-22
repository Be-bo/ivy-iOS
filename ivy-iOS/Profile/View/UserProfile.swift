//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI


struct UserProfile: View {
    
    var uid = ""
    @ObservedObject var thisUserRepo = ThisUserRepo()
    @ObservedObject var profileVM: ProfileViewModel
    @State var userPicUrl = ""
    @State var editProfile = false
    @State var seeMemberRequests = false
    @State var selection : Int? = nil
    @State private var settingsPresented = false
    @State private var notificationCenterPresented = false
    @State var alreadyRequested = false //this is for member request -> whether it's "request", "cancel", or "leave", it hides right away after click and they have to leave and come back to see the next one
    
    // for pagination of posts/events
    @State private var postLoadingWheelAnimating = true
    @State private var eventLoadingWheelAnimating = true
    
    
    init(uid: String) {
        self.profileVM = ProfileViewModel(uid: uid)
        self.uid = uid
    }
    
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                // MARK: Header
                HStack {
                    
                    // MARK: Profile Image
                    ZStack{
                        FirebaseImage(
                            path: Utils.userProfileImagePath(userId: self.uid),
                            placeholder: Image(systemName: "person.crop.circle.fill"),
                            width: 150,
                            height: 150,
                            shape: RoundedRectangle(cornerRadius: 75)
                        ).padding(.horizontal, 10)
                    }
                    
                    
                    
                    
                    // MARK: Profile Info
                    VStack (alignment: .leading){
                        Text(self.profileVM.userInfoVM.userProfile.name).padding(.bottom, 10)
                        
                        // ORG or STUD ?
                        if (profileVM.userInfoVM.userProfile.is_organization) { // ORGANIZATION
                            
                            if (profileVM.userInfoVM.userProfile.member_ids.count == 1) {
                                Text("1 Member").padding(.bottom, 10)
                            } else {
                                Text("\(profileVM.userInfoVM.userProfile.member_ids.count) Members").padding(.bottom, 10)
                            }
                        } else { // STUDENT
                            Text(self.profileVM.userInfoVM.userProfile.degree).padding(.bottom, 10)
                        }
                   
                        // 3rd person?
                        if Auth.auth().currentUser != nil && profileVM.userInfoVM.userProfile.id ?? "" == Auth.auth().currentUser!.uid { // check if this is 3rd person user
                            Button(action: {
                                self.editProfile.toggle()
                            }){
                                Text("Edit").sheet(isPresented: $editProfile, onDismiss: {
                                    
                                    // refresh profile pic
                                    FirebasePostImage.getPicUrl(picUrl: self.$userPicUrl,
                                        path: self.profileVM.userInfoVM.userProfile.profileImagePath())
                                    
                                }){
                                    EditUserProfile(userProfile: self.profileVM.userInfoVM.userProfile,
                                                    nameInput: self.profileVM.userInfoVM.userProfile.name)
                                }
                            }.padding(.bottom, 10)
                            
                        } else { // MARK: Membership Buttons
                            // user had to be logged in and not be viewing themselves 3rd party
                            if Auth.auth().currentUser != nil && profileVM.userInfoVM.userProfile.id != Auth.auth().currentUser!.uid && profileVM.userInfoVM.userProfile.is_organization {
                                
                                // MARK: Student Requesting Buttons

                                if(!alreadyRequested){
                                    // viewing user not a member
                                    if(!profileVM.userInfoVM.userProfile.member_ids.contains(Auth.auth().currentUser!.uid)){
                                        // viewing user already requested membership
                                        if(profileVM.userInfoVM.userProfile.request_ids.contains(Auth.auth().currentUser!.uid)){
                                            Button(action: {
                                                self.alreadyRequested = true
                                                self.profileVM.cancelRequest(
                                                    uid: profileVM.userInfoVM.userProfile.id)
                                            }){
                                                Text("Cancel Join Request")
                                            }
                                        } else { // neither a mem nor a req -> can request membership
                                            Button(action: {
                                                self.alreadyRequested = true
                                                self.profileVM.requestMembership(
                                                    uid: profileVM.userInfoVM.userProfile.id
                                                )
                                            }){
                                                Text("Request Membership")
                                            }
                                        }
                                    } else { // viewing user is a member
                                        Button(action: {
                                            self.alreadyRequested = true
                                            self.profileVM.leaveOrganization(
                                                uid: profileVM.userInfoVM.userProfile.id)
                                        }){
                                            Text("Leave Organization")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                
                // MARK: Members
                if(profileVM.userInfoVM.userProfile.is_organization && profileVM.userInfoVM.userProfile.member_ids.count > 0){
                    MemberListRow(memberIds: profileVM.userInfoVM.userProfile.member_ids,
                                  orgId: profileVM.userInfoVM.userProfile.id ?? "",
                                  userIsOrg: false)
                        .padding(.top, 20).padding(.bottom, 10)
                }
                
                
                // MARK: Member Requests
                if(profileVM.userInfoVM.userProfile.is_organization && profileVM.userInfoVM.userProfile.request_ids.count > 0 && Auth.auth().currentUser != nil && profileVM.userInfoVM.userProfile.id == Auth.auth().currentUser!.uid){
                    MemberListRow(memberIds: profileVM.userInfoVM.userProfile.request_ids,
                                  orgId: profileVM.userInfoVM.userProfile.id ?? "",
                                  titleText: "Member Requests", userIsOrg: false)
                        .padding(.top, 20).padding(.bottom, 20)
                }
                
                
                
                // MARK: Posts & Events
                
                ZStack{
                    
                    VStack {
                        // MARK: EVENTS
                        if (profileVM.eventVMs.count > 0) {
                            HStack {
                                Text("Events")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.$profileVM.eventVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                )
                            { eventVM in
                                ProfileEventItemView(eventVM: eventVM)
                            }
                            
                            // Load next Batch if not all loaded
                            if !profileVM.profileRepo.eventsLoaded {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        self.profileVM.profileRepo.loadEvents()
                                    }) {
                                        Text("Load More Events")
                                    }
                                    /* TODO: Activity Indicator doesn't work properly
                                     ActivityIndicator($eventLoadingWheelAnimating)
                                         .onAppear {
                                             self.profileVM.profileRepo.loadEvents()
                                         }*/
                                    
                                }
                            }
                        }
                        
                        
                        
                        // MARK: POSTS
                        if (profileVM.postVMs.count > 0) {
                            HStack {
                                Text("Posts")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.$profileVM.postVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                )
                            { postVM in
                                ProfilePostItemView(postVM: postVM)
                            }
                            
                            
                            
                            // Load next Batch if not all loaded
                            if !profileVM.profileRepo.postsLoaded {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        self.profileVM.profileRepo.loadPosts()
                                    }) {
                                        Text("Load More Posts")
                                    }
                                    /* TODO: Activity Indicator doesn't work properly
                                     ActivityIndicator($postLoadingWheelAnimating)
                                        .onAppear {
                                            print("onAppear called for posts. POSTS = \(self.profileVM.postVMs.count)")
                                            self.profileVM.profileRepo.loadPosts() }*/
                                }
                            }
                        } else if profileVM.postVMs.count == 0 && profileVM.eventVMs.count == 0 {
                            Spacer()
                            Text("No Posts or Events yet!")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(alignment: .center)
                        }
                    } .padding(.horizontal, 10)
                }
                LoadingSpinner().frame(width: UIScreen.screenWidth, height: 5).hidden()   // TODO: quick and dirty
            }
            .padding(.horizontal).padding(.top)
            .onAppear(){
                self.userPicUrl = "" //force reload
            }
        }
    }
}






