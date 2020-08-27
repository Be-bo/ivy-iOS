//
//  HomePostItemView.swift
//  ivy-iOS
//
//  Created by Robert on 2020-08-23.
//  Copyright © 2020 ivy. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct HomePostView: View {
    var thisUserIsOrg: Bool
    @ObservedObject var postItemVM: HomePostViewModel
    @State var url = ""
    @State var authorUrl = ""
    @State var selection: Int? = nil
    var onCommit: (Post) -> (Void) = {_ in}
    
    
    var body: some View {
        HStack{
            
            // MARK: Author & Time
            VStack{
                WebImage(url: URL(string: authorUrl))
                    .resizable()
                    .placeholder(Image(systemName: "person.crop.circle.fill"))
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .onAppear(){
                        let storage = Storage.storage().reference()
                        storage.child(Utils.userPreviewImagePath(userId: self.postItemVM.post.author_id)).downloadURL { (url, err) in
                            if err != nil{
                                print("Error loading event image.")
                                return
                            }
                            self.authorUrl = "\(url!)"
                        }
                    }
                    
                    if postItemVM.post.creation_millis != nil {
                        Text(Utils.getHumanTimeFromMillis(millis: Double(postItemVM.post.creation_millis!)))
                            .foregroundColor(AssetManager.ivyLightGrey)
                    }
                    
                    Spacer()
                }
            
            
            // MARK: Post Content
            VStack{
                // MARK: Text
                ZStack(alignment: .leading){ //a little trick to get rid of the default navlink arrow
                    Button(action: {
                        self.selection = 1
                    }){
                        Text(self.postItemVM.post.text).multilineTextAlignment(.leading).padding(.bottom, 10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: PostScreen(postVM: postItemVM, thisUserIsOrg: self.thisUserIsOrg).navigationBarTitle(postItemVM.post.author_name+"'s Post"), tag: 1, selection: self.$selection) { //both post and image are clickable for post screen transition
                        EmptyView()
                    }
                }
                
                
                // MARK: Pinned Layout
                if(self.postItemVM.post.pinned_id != "" && self.postItemVM.post.pinned_id != "nothing"){
                    HStack{
                        Image(systemName: "pin.fill").rotationEffect(Angle(degrees: -45)).padding(.leading, 5)
                        Text(self.postItemVM.post.pinned_name).foregroundColor(AssetManager.ivyGreen)
                        Spacer()
                    }
                }
                
                
                // MARK: Image
                if(postItemVM.post.visual != "" && postItemVM.post.visual != "nothing"){
                    ZStack{ //little trick to remove the default navlink arrow
                        Button(action: {
                            self.selection = 2
                        }){
                            WebImage(url: URL(string: url)) //TODO: event image
                                .resizable()
                                .placeholder(AssetManager.logoWhite)
                                .background(AssetManager.ivyLightGrey)
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                .onAppear(){
                                    let storage = Storage.storage().reference()
                                    storage.child(self.postItemVM.post.visual).downloadURL { (url, err) in
                                        if err != nil{
                                            print("Error loading post image.")
                                            return
                                        }
                                        self.url = "\(url!)"
                                    }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: PostScreen(postVM: postItemVM, thisUserIsOrg: self.thisUserIsOrg).navigationBarTitle(postItemVM.post.author_name+"'s Post"), tag: 2, selection: self.$selection) { //both post and image are clickable for post screen transition
                            EmptyView()
                        }
                    }
                }   
            }
            .padding(.leading, 10)
        }
        .padding(.top, 15)
        .padding(.bottom, 15)
    }
}
