//
//  StudentProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct StudentProfile: View {
    @ObservedObject var thisUserRepo = ThisUserRepo()
    @ObservedObject var profileVM: ProfileViewModel
    var uid = ""
    @State var editProfile = false
    @State var selection : Int? = nil
    @State var userPicUrl = ""
    @State private var settingsPresented = false
    @State private var notificationCenterPresented = false
    
    @State private var postLoadingWheelAnimating = true
    @State private var eventLoadingWheelAnimating = true
    
    
    init(uid: String) {
        self.profileVM = ProfileViewModel(uid: uid)
        self.uid = uid
    }
    
    var body: some View {
        
        ScrollView() {
            VStack (alignment: .leading) {
                
                // MARK: Header
                HStack {
                    
                    // MARK: Profile Image
                    WebImage(url: URL(string: userPicUrl))
                        .resizable()
                        .placeholder(Image(systemName: "person.crop.circle.fill"))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .onAppear(){
                            self.userPicUrl = ""
                            let storage = Storage.storage().reference()
                            storage.child(Utils.userProfileImagePath(userId: self.uid)).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading org profile image.")
                                    return
                                }
                                self.userPicUrl = "\(url!)"
                            }
                    }.padding(.trailing, 10)
                    
                    // MARK: Text Info
                    VStack (alignment: .leading){
                        Text(profileVM.userInfoVM.userProfile.name).padding(.bottom, 10)
                        Text(profileVM.userInfoVM.userProfile.degree).padding(.bottom, 10)
                        
                        // If this is thisUserProfile, then show edit button
                        if Auth.auth().currentUser != nil && profileVM.userInfoVM.userProfile.id ?? "" == Auth.auth().currentUser!.uid {
                            Button(action: {
                                self.editProfile.toggle()
                            }){
                                Text("Edit").sheet(isPresented: $editProfile, onDismiss: { //refresh pic and posts
                                    let storage = Storage.storage().reference()
                                    storage.child(self.profileVM.userInfoVM.userProfile.profileImagePath()).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading org profile image.")
                                            return
                                        }
                                        self.userPicUrl = "\(url!)"
                                    }
                                }){
                                    //                                    EditStudentProfile(thisUserRepo: self.userRepo as! ThisUserRepo)
                                    EditOrganizationProfile(userProfile: self.profileVM.userInfoVM.userProfile, nameInput: self.profileVM.userInfoVM.userProfile.name)
                                }
                            }.padding(.bottom, 10)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                
                
                // MARK: Post & Events
                
                ZStack{
                    VStack(alignment: .center){
                        // MARK: EVENTS
                        if (self.profileVM.userEventVMs.count > 0) {
                            HStack {
                                Text("Events")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.profileVM.userEventVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                ) //{ geo in
                            { eventVM in
                                ProfileEventItemView(eventVM: eventVM)
                            }
                            //}
                            
                            // Load next Batch if not all loaded
                            if !profileVM.profileRepo.eventsLoaded {
                                HStack {
                                    Spacer()
                                    ActivityIndicator($eventLoadingWheelAnimating)
                                        .onAppear {
                                            if (self.profileVM.userEventVMs.count < 1) {
                                                self.profileVM.profileRepo.loadEvents(start: true)
                                            } else {
                                                self.profileVM.profileRepo.loadEvents()
                                            }
                                        }
                                    Spacer()
                                }
                            }
                        }
                        
                        // MARK: POSTS
                        if (self.profileVM.userPostVMs.count > 0) {
                            HStack {
                                Text("Posts")
                                Spacer()
                            }
                            
                            GridView(
                                cells: self.profileVM.userPostVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                                ) //{ geo in
                            { postVM in
                                ProfilePostItemView(postVM: postVM)
                            }
                            //}
                            
                            // Load next Batch if not all loaded
                            if !profileVM.profileRepo.postsLoaded {
                                HStack {
                                    Spacer()
                                    ActivityIndicator($postLoadingWheelAnimating)
                                        .onAppear {
                                            if (self.profileVM.userPostVMs.count < 1) {
                                                self.profileVM.profileRepo.loadPosts(start: true)
                                            } else {
                                                self.profileVM.profileRepo.loadPosts()
                                            }
                                        }
                                    Spacer()
                                }
                            }
                        }
                            
                        else {
                            Spacer()
                            Text("No Posts or Events yet!")
                                .foregroundColor(.gray)
                                .padding()
                                .frame(alignment: .center)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                LoadingSpinner().frame(width: UIScreen.screenWidth, height: 5, alignment: .center).hidden()   // TODO: quick and dirty
                
            }
            .padding(.horizontal)
            .onAppear(){
                self.userPicUrl = "" //force reload
            }
        }
    }
}

