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
    @ObservedObject var uniInfo = UniInfo()
    @ObservedObject private var thisUserRepo = ThisUserRepo()
    @State private var settingsPresented = false
    @State private var createPostOrLoginPresented = false
    @State private var notificationCenterPresented = false
    
    @ObservedObject var userRepo: UserRepo
    @ObservedObject var postListVM : PostListViewModel
    @State var editProfile = false
    @State var selection : Int? = nil
    
    
    init(userRepo: UserRepo, postListVM : PostListViewModel) {
        self.userRepo = userRepo
        self.postListVM = postListVM
    }
    
    init(userRepo: UserRepo, uni_domain: String, user_id: String) {
        self.userRepo = userRepo
        self.postListVM = PostListViewModel(
            limit: Constant.PROFILE_POST_LIMIT_STUDENT,
            uni_domain: uni_domain,
            user_id: user_id
        )
    }
    
    var body: some View {
        
        NavigationView{
            ScrollView {
                VStack (alignment: .leading) {
                    
                    
                    // MARK: Header
                    HStack {
                        
                        // MARK: Image
                        FirebaseImage(
                            path: userRepo.user.profileImagePath(),
                            placeholder: Image(systemName: "person.crop.circle.fill"),
                            width: 150,
                            height: 150,
                            shape: Circle()
                        )
                            .padding(.trailing, 10)
                        
                        // MARK: Text Info
                        VStack (alignment: .leading){
                            Text(userRepo.user.name).padding(.bottom, 10)
                            Text(userRepo.user.degree).padding(.bottom, 10)
                            
                            // If this is thisUserProfile, then show edit button
                            if userRepo is ThisUserRepo {
                                Button(action: {
                                    self.editProfile.toggle()
                                }){
                                    Text("Edit").sheet(isPresented: $editProfile){
                                        EditStudentProfile(thisUserRepo: self.userRepo as! ThisUserRepo)
                                    }
                                }.padding(.bottom, 10)
                            }
                        }
                        Spacer()
                    }
                    
                    
                    // Posts
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
                })
                    .onDisappear { //stop listening to realtime updates
                        self.userRepo.removeListener()
                }
            }
                
                // MARK: Nav Bar
                .navigationBarItems(leading:
                    HStack {
                        Button(action: {
                            self.settingsPresented.toggle()
                        }) {
                            Image(systemName: "gear").font(.system(size: 25))
                                .sheet(isPresented: $settingsPresented){
                                    SettingsView(uniInfo: self.uniInfo)
                            }
                        }
                        
                        WebImage(url: URL(string: self.uniInfo.uniLogoUrl))
                            .resizable()
                            .placeholder(AssetManager.uniLogoPlaceholder)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(.leading, (UIScreen.screenWidth/2 - 80))
                            .onAppear(){
                                let storage = Storage.storage().reference()
                                storage.child(Utils.uniLogoPath()).downloadURL { (url, err) in
                                    if err != nil{
                                        print("Error loading uni logo image.")
                                        return
                                    }
                                    self.uniInfo.uniLogoUrl = "\(url!)"
                                }
                        }
                        
                    }.padding(.leading, 0), trailing:
                    HStack {
                        Button(action: {
                            self.notificationCenterPresented.toggle()
                        }) {
                            Image(systemName: "bell").font(.system(size: 25))
                                .sheet(isPresented: $notificationCenterPresented){
                                    NotificationCenterView()
                            }
                        }
                    })
            
        }
        
    }
}

