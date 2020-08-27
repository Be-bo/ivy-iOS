//
//  PostScreen.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct PostScreen: View {
    @ObservedObject var postVM: HomePostViewModel
    var pinnedEventVM: EventItemViewModel
    @State var imageUrl = ""
    @State var authorUrl = ""
    var onCommit: (Post) -> (Void) = {_ in}
    
    @State private var selection : Int? = nil
    
    
    init(postVM: HomePostViewModel){
        self.postVM = postVM
        pinnedEventVM = EventItemViewModel(event: postVM.pinnedEvent)
    }
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true){
            
            VStack{
                
                //MARK: Image
                if(postVM.post.visual != "" && postVM.post.visual != "nothing"){
                    WebImage(url: URL(string: self.imageUrl))
                        .resizable()
                        .placeholder(AssetManager.logoWhite)
                        .background(AssetManager.ivyLightGrey)
                        .aspectRatio(contentMode: .fit)
                        .onAppear(){
                            let storage = Storage.storage().reference()
                            storage.child(self.postVM.post.visual).downloadURL { (url, err) in
                                if err != nil{
                                    print("Error loading post screen image.")
                                    return
                                }
                                self.imageUrl = "\(url!)"
                            }
                    }
                }
                
                
                VStack(alignment: .leading){
                    //MARK: Author Row
                    ZStack{
                        HStack(){
                            WebImage(url: URL(string: authorUrl))
                                .resizable()
                                .placeholder(Image(systemName: "person.crop.circle.fill"))
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .onAppear(){
                                    let storage = Storage.storage().reference()
                                    storage.child(Utils.userPreviewImagePath(userId: self.postVM.post.author_id)).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading post screen author image.")
                                            return
                                        }
                                        self.authorUrl = "\(url!)"
                                    }
                            }
                            Text(self.postVM.post.author_name)
                            Spacer()
                        }
                        .onTapGesture {
                            self.selection = 1
                        }
                        
                        
                        if (postVM.post.author_is_organization) {
                            NavigationLink(
                                destination: OrganizationProfile(
                                    userRepo: UserRepo(userid: postVM.post.author_id),
                                    uni_domain: postVM.post.uni_domain,
                                    user_id: postVM.post.author_id
                                )
                                    .navigationBarTitle("Profile"),
                                tag: 1,
                                selection: self.$selection) {
                                    EmptyView()
                            }
                        } else {
                            NavigationLink(
                                destination: StudentProfile(
                                    userRepo: UserRepo(userid: postVM.post.author_id),
                                    uni_domain: postVM.post.uni_domain,
                                    user_id: postVM.post.author_id
                                )
                                    .navigationBarTitle("Profile"),
                                tag: 1,
                                selection: self.$selection) {
                                    EmptyView()
                            }
                        }
                        
                    }
                    
                    // MARK: Pinned Layout
                    if(self.postVM.post.pinned_id != "" && self.postVM.post.pinned_id != "nothing"){
                        HStack{
                            Image(systemName: "pin.fill").rotationEffect(Angle(degrees: -45))
                            ZStack{
                                Text(self.postVM.post.pinned_name).foregroundColor(AssetManager.ivyGreen).padding(.top, 5)
                                    .onTapGesture {
                                        self.selection = 2
                                }
                                NavigationLink(destination: EventScreenView(eventVM: pinnedEventVM).navigationBarTitle(postVM.post.pinned_name), tag: 2, selection: self.$selection){
                                    EmptyView()
                                }
                                Spacer()
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    
                    // MARK: Text
                    Text(postVM.post.text).multilineTextAlignment(.leading)
 
                }
                .padding(.horizontal)
                
                Divider().padding(.top, 20).padding(.bottom, 20)
                Text("Comments coming soon!").font(.system(size: 25)).foregroundColor(AssetManager.ivyLightGrey).multilineTextAlignment(.center).padding(.top, 30).padding(.bottom, 30)
            }
        }
    }
}

