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
                                EditStudentProfile()
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
                        if (postListVM.posts.count > 0) {
                            HStack {
                                Text("Posts")
                                Spacer()
                            }
                            
                            GridView(
                                cells: postListVM.posts,
                                maxCol: 3
                            ) { post in
                                GeometryReader { geo in
                                    //TODO: ASK ROBERT
                                    //NavigationLink(destination: PostScreen()) {

                                     FirebaseImage(
                                         path: Utils.postPreviewImagePath(postId: post.id ?? "nil"),
                                         placeholder: AssetManager.logoGreen,
                                         width: geo.size.width/3,
                                         height: geo.size.width/3,
                                         shape: RoundedRectangle(cornerRadius: 25)
                                     )
                                     
                                    //}
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
