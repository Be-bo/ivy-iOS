//
//  StudentProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI

struct StudentProfile: View {
    
    @ObservedObject var thisUserRepo: ThisUserRepo
    @ObservedObject var postListVM = PostListViewModel()
    @State var editProfile = false
    @State var selection : Int? = nil
    
    
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
            VStack (alignment: .leading) {
                
                HStack { // Profile image and quick info
                    
                    FirebaseImage(
                        path: thisUserRepo.thisUser.profileImagePath(),
                        placeholder: Image(systemName: "person.crop.circle.fill"),
                        width: 100,
                        height: 100,
                        shape: Circle()
                    )
                        .padding(.trailing, 10)
                    
                    VStack (alignment: .leading){
                        
                        Text(thisUserRepo.thisUser.name)
                        Text(thisUserRepo.thisUser.degree)
                            .padding(.bottom)
                        
                        
                        Button(action: {
                            self.editProfile.toggle()
                        }){
                            Text("Edit").sheet(isPresented: $editProfile){
                                EditStudentProfile(thisUserRepo: self.thisUserRepo)
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
                            
                            GridView(
                                cells: self.postListVM.postVMs,
                                maxCol: Constant.PROFILE_POST_GRID_ROW_COUNT
                            ) { geo in
                                { postVM in
                                    ZStack {
                                        Button(action: {
                                            self.selection = 1
                                        }){
                                            FirebaseImage(
                                                path: Utils.postPreviewImagePath(postId: postVM.id),
                                                placeholder: AssetManager.logoGreen,
                                                width: geo.size.width/CGFloat(Constant.PROFILE_POST_GRID_ROW_COUNT),
                                                height: geo.size.width/CGFloat(Constant.PROFILE_POST_GRID_ROW_COUNT),
                                                shape: RoundedRectangle(cornerRadius: 25)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())

                                        // TODO: quick and dirty
                                        NavigationLink(
                                            destination: PostScreen(postVM: postVM)
                                                .navigationBarTitle(postVM.post.author_name+"'s Post"),
                                            tag: 1, selection: self.$selection)
                                        { EmptyView() }
                                    }
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
                }
            }
            .padding(.horizontal)
        }
    }
}
