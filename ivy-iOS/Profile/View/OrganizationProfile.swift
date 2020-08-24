//
//  OrganizationProfile.swift
//  ivy-iOS
//
//  Created by Zahra Ghavasieh on 2020-08-20.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI


struct OrganizationProfile: View {
    
    @ObservedObject var thisUserRepo: ThisUserRepo
    @ObservedObject var postListVM = PostListViewModel()
    @State var editProfile = false
    @State var seeMemberRequests = false
    
    
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
                    
                    //MARK: TODO test image
                    //FirebaseImage(id: "userfiles/testID/test_flower.jpg")
                    Image("LogoGreen")
                    .resizable()
                    .frame(width: 150, height: 150)
                    
                    VStack (alignment: .leading){
                        
                        Text(thisUserRepo.thisUser.name)
                        Text("Members")
                            .padding(.bottom)
                        
                        Button(action: {
                            self.seeMemberRequests.toggle()
                        }){
                            Text("Member Requests").sheet(isPresented: $seeMemberRequests){
                                SeeAllUsers()
                            }
                        }
                        
                        Button(action: {
                            self.editProfile.toggle()
                        }){
                            Text("Edit").sheet(isPresented: $editProfile){
                                EditOrganizationProfile()
                            }
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                
                SeeMembers()
                
                
                // Posts
                VStack() {
                    if (postListVM.postsLoaded == true) {
                        if (postListVM.postVMs.count > 0) {
                            Text("Posts")
                            
                            NavigationView {
                                GridView(
                                    cells: postListVM.postVMs,
                                    maxCol: 3
                                ) { geo in
                                    { postVM in
                                        //TODO: ASK ROBERT
                                        //NavigationLink(destination: PostScreen(postVM: )) {

                                         FirebaseImage(
                                             path: Utils.postPreviewImagePath(postId: postVM.id),
                                             placeholder: AssetManager.logoGreen,
                                             width: geo.size.width/3,
                                             height: geo.size.width/3,
                                             shape: RoundedRectangle(cornerRadius: 25)
                                         )
                                         
                                        //}
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
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
}

/* SubViews */

struct SeeMembers: View {
    var body: some View {
        VStack {
            Text("Members")
            
            ScrollView {
                HStack {
                    ForEach(1...5, id: \.self) {_ in
                        Image("LogoGreen")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
            }
        }
    }
}
