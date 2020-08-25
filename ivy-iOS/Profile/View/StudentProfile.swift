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
        ScrollView {
            VStack (alignment: .leading) {
                
                HStack { // Profile image and quick info
                    
                    FirebaseImage(
                        path: userRepo.user.profileImagePath(),
                        placeholder: Image(systemName: "person.crop.circle.fill"),
                        width: 100,
                        height: 100,
                        shape: Circle()
                    )
                        .padding(.trailing, 10)
                    
                    VStack (alignment: .leading){
                        
                        Text(userRepo.user.name)
                        Text(userRepo.user.degree)
                            .padding(.bottom)
                        
                        // If this is thisUserProfile, then show edit button
                        if userRepo is ThisUserRepo {
                            Button(action: {
                                self.editProfile.toggle()
                            }){
                                Text("Edit").sheet(isPresented: $editProfile){
                                    EditStudentProfile(thisUserRepo: self.userRepo as! ThisUserRepo)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.top)

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
        }
    }
}
