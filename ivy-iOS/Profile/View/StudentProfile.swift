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
    @ObservedObject private var thisUserRepo = ThisUserRepo()
    @ObservedObject var userRepo: UserRepo
    @ObservedObject var postListVM : PostListViewModel
    @State var editProfile = false
    @State var selection : Int? = nil
    @State var userPicUrl = ""
    
    
    init(userRepo: UserRepo, postListVM : PostListViewModel) {
        self.userRepo = userRepo
        self.postListVM = postListVM
    }
    
    init(userRepo: UserRepo, uni_domain: String, user_id: String) {
        self.userRepo = userRepo
        self.postListVM = PostListViewModel()
        self.postListVM.loadPosts(
            limit: Constant.PROFILE_POST_LIMIT_STUDENT,
            uni_domain: uni_domain,
            user_id: user_id)
    }
    
    var body: some View {
        ScrollView {
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
                        .padding(.trailing, 10)
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(self.userRepo.user.profileImagePath()).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading org profile image.")
                                    return
                                }
                                self.userPicUrl = "\(url!)"
                            }
                    }.padding(.trailing, 10)
                    
                    // MARK: Text Info
                    VStack (alignment: .leading){
                        Text(userRepo.user.name).padding(.bottom, 10)
                        Text(userRepo.user.degree).padding(.bottom, 10)
                        
                        // If this is thisUserProfile, then show edit button
                        if userRepo is ThisUserRepo {
                            Button(action: {
                                self.editProfile.toggle()
                            }){
                                Text("Edit").sheet(isPresented: $editProfile, onDismiss: {
                                    let storage = Storage.storage().reference()
                                    storage.child(self.userRepo.user.profileImagePath()).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading org profile image.")
                                            return
                                        }
                                        self.userPicUrl = "\(url!)"
                                    }
                                }){
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
                if(!self.userRepo.userDocLoaded){ // if not loaded, start listening again
                    self.userRepo.loadUserProfile()
                }
                if (!self.postListVM.postsLoaded){ // start listening if not loaded yet
                    self.postListVM.loadPosts(
                        limit: Constant.PROFILE_POST_LIMIT_STUDENT,
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
}

