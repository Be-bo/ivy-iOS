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
    
    @ObservedObject var userRepo: UserRepo
    @ObservedObject var postListVM = PostListViewModel()
    @State var editProfile = false
    @State var selection : Int? = nil
        
    
    init(userRepo: UserRepo) {
        self.userRepo = userRepo
        self.postListVM.loadPosts(
            limit: Constant.PROFILE_POST_LIMIT_STUDENT,
            uni_domain: userRepo.user.uni_domain,
            user_id: userRepo.user.id ?? ""
        )
    }
    
    var body: some View {
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
                VStack() {
                    if (postListVM.postsLoaded == true) {
                        if (postListVM.postVMs.count > 0) {
                            HStack {
                                Text("Posts")
                                Spacer()
                            }
                            
                            //TODO: quick and dirty
                            GridView(
                                cells: self.postListVM.postVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                            ) //{ geo in
                                { postVM in
                                    ZStack {
                                        /*Button(action: {
                                            self.selection = postVM.post.creation_millis ?? 1
                                            print("selected post: \(postVM.post.text)")
                                        }){*/
                                            FirebaseImage(
                                                path: Utils.postPreviewImagePath(postId: postVM.id),
                                                placeholder: AssetManager.logoGreen,
                                                width: 105,
                                                height: 105,
                                                shape: RoundedRectangle(cornerRadius: 25)
                                            )
                                                .onTapGesture {
                                                    self.selection = postVM.post.creation_millis ?? 1
                                                    print("selected post: \(postVM.post.text)")
                                            }
                                        //}
                                        //.buttonStyle(PlainButtonStyle())

                                        // TODO: quick and dirty
                                        NavigationLink(
                                            destination: PostScreen(postVM: postVM)
                                                .navigationBarTitle(postVM.post.author_name+"'s Post"),
                                            tag: postVM.post.creation_millis ?? 1, selection: self.$selection)
                                        { EmptyView() }
                                    }
                                //}

                            }
                        } else {
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
    }
}
