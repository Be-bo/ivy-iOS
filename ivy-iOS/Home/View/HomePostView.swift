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
    @ObservedObject var postItemVM: HomePostViewModel
    @State var url = ""
    @State var authorUrl = ""
    @State var selection: Int? = nil
    var onCommit: (Post) -> (Void) = {_ in}
    
    
    var body: some View {
        HStack{
            
            // MARK: Author & Time
            VStack{

                FirebaseImage(
                    path: Utils.userPreviewImagePath(userId: self.postItemVM.post.author_id),
                    placeholder: Image(systemName: "person.crop.circle.fill"),
                    width: 40,
                    height: 40,
                    shape: RoundedRectangle(cornerRadius: 20)
                )
                    
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
                        Text(self.postItemVM.post.text)
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: PostScreen(postVM: postItemVM).navigationBarTitle(Text(postItemVM.post.author_name+"'s Post"), displayMode: .inline), tag: 1, selection: self.$selection) { //both post and image are clickable for post screen transition
                        EmptyView()
                    }
                }
                .padding(.top, 8)
                
                Spacer()
                
                
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
                            FirebaseImage(
                                path: Utils.postPreviewImagePath(postId: postItemVM.post.id!),
                                placeholder: AssetManager.logoGreen,
                                width: (UIScreen.screenWidth - 100),
                                height: (UIScreen.screenWidth - 100),
                                shape: RoundedRectangle(cornerRadius: 25)
                            )
                        
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: PostScreen(postVM: postItemVM).navigationBarTitle(Text(postItemVM.post.author_name+"'s Post"), displayMode: .inline), tag: 2, selection: self.$selection) { //both post and image are clickable for post screen transition
                            EmptyView()
                        }
                    }
                }   
            }
            .padding(.leading, 10)
        }
        .padding(.vertical, 10)
    }
}
