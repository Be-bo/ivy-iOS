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
    
    @ObservedObject var thisUserRepo : ThisUserRepo
    @ObservedObject var profileVM : ProfileViewModel
    @Binding var picUrl : String
    var uid : String
    
    @State var seeMemberRequests = false
    @State var selection : Int? = nil
    @State private var settingsPresented = false
    @State private var notificationCenterPresented = false
    @State var alreadyRequested = false //this is for member request -> whether it's "request", "cancel", or "leave", it hides right away after click and they have to leave and come back to see the next one
    
    // for pagination of posts/events
    @State private var postLoadingWheelAnimating = true
    @State private var eventLoadingWheelAnimating = true
    
    
    
    // First person profile for tab bar
    init(thisUserRepo: ThisUserRepo, profileVM: ProfileViewModel, picUrl: Binding<String>, uid: String){
        self.thisUserRepo = thisUserRepo
        self.profileVM = profileVM
        self._picUrl = picUrl
        self.uid = uid
    }
    
    
    // Third person Profile
    init(uid: String){
        self.init(
            thisUserRepo: ThisUserRepo(),
            profileVM: ProfileViewModel(uid: uid),
            picUrl: Binding.constant(Utils.userProfileImagePath(userId: uid)),
            uid: uid
            )
    }
    

    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading){
                
                // MARK: Header
                HStack {
                    
                    // MARK: Profile Image
                    FirebaseImage(
                        path: self.$picUrl,
                        placeholder: Image(systemName: "person.crop.circle.fill"),
                        width: 150,
                        height: 150,
                        shape: RoundedRectangle(cornerRadius: 75)
                    ).padding(.horizontal, 10)
                                        
                    
                    // MARK: Profile Info
                    VStack (alignment: .leading){
                        Text(self.profileVM.profileRepo.userProfile.name).padding(.bottom, 10)
                        
                        // ORG or STUD ?
                        if (profileVM.profileRepo.userProfile.is_organization) { // ORGANIZATION
                            
                            if (profileVM.profileRepo.userProfile.member_ids?.count == 1) {
                                Text("1 Member").padding(.bottom, 10)
                            } else {
                                Text("\(profileVM.profileRepo.userProfile.member_ids!.count) Members").padding(.bottom, 10)
                            }
                        } else { // STUDENT
                            Text(self.profileVM.profileRepo.userProfile.degree ?? "").padding(.bottom, 10)
                        }
                   
                        // 3rd person? -> show membership buttons
                        if Auth.auth().currentUser == nil || profileVM.profileRepo.userProfile.id != Auth.auth().currentUser!.uid { // check if this is 3rd person user

                            // MARK: Membership Buttons
                            // user had to be logged in and not be viewing themselves 3rd party
                            if Auth.auth().currentUser != nil && profileVM.profileRepo.userProfile.id != Auth.auth().currentUser!.uid && profileVM.profileRepo.userProfile.is_organization {
                                
                                // MARK: Student Requesting Buttons

                                if(!alreadyRequested){
                                    // viewing user not a member
                                    if(profileVM.profileRepo.userProfile.member_ids!.contains(Auth.auth().currentUser!.uid)){
                                        // viewing user already requested membership
                                        if(profileVM.profileRepo.userProfile.request_ids!.contains(Auth.auth().currentUser!.uid)){
                                            Button(action: {
                                                self.alreadyRequested = true
                                                self.profileVM.cancelRequest(
                                                    uid: profileVM.profileRepo.userProfile.id)
                                            }){
                                                Text("Cancel Join Request")
                                            }
                                        } else { // neither a mem nor a req -> can request membership
                                            Button(action: {
                                                self.alreadyRequested = true
                                                self.profileVM.requestMembership(
                                                    uid: profileVM.profileRepo.userProfile.id
                                                )
                                            }){
                                                Text("Request Membership")
                                            }
                                        }
                                    } else { // viewing user is a member
                                        Button(action: {
                                            self.alreadyRequested = true
                                            self.profileVM.leaveOrganization(
                                                uid: profileVM.profileRepo.userProfile.id)
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
                if(profileVM.profileRepo.userProfile.is_organization && profileVM.profileRepo.userProfile.member_ids!.count > 0){
                    MemberListRow(memberIds: profileVM.profileRepo.userProfile.member_ids!,
                                  orgId: profileVM.profileRepo.userProfile.id,
                                  userIsOrg: false)
                        .padding(.top, 20).padding(.bottom, 10)
                }
                
                
                // MARK: Member Requests
                if(profileVM.profileRepo.userProfile.is_organization && profileVM.profileRepo.userProfile.request_ids!.count > 0 && Auth.auth().currentUser != nil && profileVM.profileRepo.userProfile.id == Auth.auth().currentUser!.uid){
                    MemberListRow(memberIds: profileVM.profileRepo.userProfile.request_ids!,
                                  orgId: profileVM.profileRepo.userProfile.id,
                                  titleText: "Member Requests", userIsOrg: false)
                        .padding(.top, 20).padding(.bottom, 20)
                }
                
                
                
                // MARK: Posts & Events
                
                ZStack {
                    
                    VStack {
                        // MARK: EVENTS
                        UserPosts(
                            title: "Events",
                            array: self.$profileVM.eventVMs,
                            cellView: { eventVM in
                                ProfileEventItemView(eventVM: eventVM)
                            },
                            loadMoreCond: !profileVM.profileRepo.eventsLoaded,
                            loadMoreAction: {
                                self.profileVM.profileRepo.loadEvents()
                            }
                        )
                        
                        
                        
                        // MARK: POSTS
                        UserPosts(
                            title: "Posts",
                            array: self.$profileVM.postVMs,
                            cellView: { postVM in
                                ProfilePostItemView(postVM: postVM)
                            },
                            loadMoreCond: !profileVM.profileRepo.postsLoaded,
                            loadMoreAction: {
                                self.profileVM.profileRepo.loadPosts()
                            }
                        )
                        
                        if profileVM.postVMs.count == 0 && profileVM.eventVMs.count == 0 {
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
        }
    }
}


// Subview of UserProfile
// Shows a grid of posts or events
struct UserPosts<T, Label>: View where Label : View, T : Identifiable {
    
    var title: String?
    @Binding var array: [T]
    var cellView : ((T) -> Label)
    var loadMoreCond : Bool
    var loadMoreAction : (() -> Void)

    
    var body: some View {
        
        Group {
            if (array.count > 0) {
                HStack {
                    Text(title ?? "")
                    Spacer()
                }
                
                GridView(
                    cells: self.$array,
                    maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT,
                    cellView: cellView)
                
                // Load next Batch if not all loaded
                if (loadMoreCond) {
                    HStack {
                        Spacer()
                        Button(action: self.loadMoreAction) {
                            Text("Load More \(title ?? "")")
                        }
                        /*
                         TODO: Activity Indicator doesn't work properly
                         ActivityIndicator($postLoadingWheelAnimating)
                            .onAppear {
                                print("onAppear called for posts. POSTS = \(self.profileVM.postVMs.count)")
                                self.profileVM.profileRepo.loadPosts() }*/
                    }
                }
            }
        }
    }
}




