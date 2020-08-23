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
                WebImage(url: URL(string: authorUrl))
                    .resizable()
                    .placeholder(Image(systemName: "person.crop.circle.fill"))
                    .frame(width: 60, height: 60)
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
//                Text(String(postItemVM.post.creation_millis))
                //TODO: human time
                Spacer()
            }
            
            
            // MARK: Post Content
            VStack{
                
                // MARK: Text
                TextField("Text", text: $postItemVM.post.text, onCommit: {
                    self.onCommit(self.postItemVM.post)
                })
                    .disabled(true)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)
                
                
                // MARK: Pinned Layout
                if(self.postItemVM.post.pinned_id != "" && self.postItemVM.post.pinned_id != "nothing"){
                    HStack{
                        AssetManager.pinIcon.resizable().frame(width: 20, height: 20, alignment: .leading)
                        Text(self.postItemVM.post.pinned_name)
                        Spacer()
                    }
                }
                
                // MARK: Image
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
            .padding(.leading, 10)

            
        }
        .padding(.top, 30)
        .padding(.bottom, 30)
    }
}
